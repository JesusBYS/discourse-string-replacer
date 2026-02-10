# name: discourse-string-replacer
# about: Remplace "\u003e" et "jesusbys" par leurs versions corrigées avant sauvegarde.
# version: 0.1
# authors: VotreNom
# url: https://github.com/VOTRE_NOM_UTILISATEUR/discourse-string-replacer

after_initialize do
  reloadable_patch do |plugin|
    Post.class_eval do
      before_save :sanitize_custom_strings

      def sanitize_custom_strings
        return if self.raw.blank?
        return unless raw_changed?

        # Remplacement de \u003e par >
        self.raw.gsub!(/\\u003e/i, '>')

        # Remplacement de jesusbys (insensible à la casse) par JesusBYS
        self.raw.gsub!(/jesusbys/i, 'JesusBYS')
      end
    end
  end
end
