# name: discourse-string-replacer
# about: Remplace littéralement \u003e par > dans tous les posts (Humain, API, IA)
# version: 0.4
# authors: JesusBYS
# url: https://github.com/JesusBYS/discourse-string-replacer

after_initialize do
  module ::StringReplacerExtension
    def self.apply_replacements(post)
      return if post.raw.blank?

      # On stocke le texte original pour comparer
      original_raw = post.raw.dup

      # Remplacements
      post.raw.gsub!("\u003e", ">")
      post.raw.gsub!("&gt;", ">")
      # post.raw.gsub!(/jesusbys/i, "JesusBYS")

      # Si on a modifié le texte et que le post est déjà enregistré (ex: traduction),
      # on s'assure que le champ "cooked" sera régénéré.
      if post.raw != original_raw && post.persisted?
        post.cooked = nil 
      end
    end
  end

  class ::Post
    # before_validation est déclenché par PostCreator, PostRevisor 
    # et les services de traduction de Discourse AI
    before_validation do
      StringReplacerExtension.apply_replacements(self)
    end
  end
end
