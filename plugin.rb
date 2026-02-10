# name: discourse-string-replacer
# about: Remplace littéralement \u003e par > dans tous les posts (Humain, API, IA)
# version: 0.4
# authors: JesusBYS
# url: https://github.com/JesusBYS/discourse-string-replacer

after_initialize do
  
  # 1. Méthode de nettoyage universelle
  def fix_unicode_greater_than(post)
    return if post.raw.blank?

    # On cible la chaîne littérale \u003e
    if post.raw.include?('\u003e') || post.raw.include?('\\u003e')
      new_raw = post.raw.gsub(/\\u003e/i, '>')
      
      # Mise à jour silencieuse en BDD pour éviter les boucles infinies de hooks
      post.update_columns(raw: new_raw)
      
      # On force la régénération du HTML pour que l'affichage change immédiatement
      post.rebake!
    end
  end

  # 2. Hook avant sauvegarde (Standard)
  on(:post_created) do |post|
    fix_unicode_greater_than(post)
  end

  # 3. Hook après modification (IA / Traductions / Éditions)
  # post_processed est déclenché quand le HTML est prêt, c'est le moment idéal pour corriger
  on(:post_processed) do |post|
    fix_unicode_greater_than(post)
  end

end
