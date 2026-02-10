# name: discourse-string-replacer
# about: Replace strings by another.
# version: 0.1
# authors: JesusBYS
# url: https://github.com/JesusBYS/discourse-string-replacer

after_initialize do
  reloadable_patch do |plugin|
    Post.class_eval do
      before_save :sanitize_custom_strings

      def sanitize_custom_strings
        return if self.raw.blank?
        return unless raw_changed?

        # On essaie de capturer la chaîne littérale ET le caractère échappé
        # On utilise une syntaxe plus robuste pour Ruby
        self.raw.gsub!(/\\u003e/i, '>')
        self.raw.gsub!("\u003e", '>')

        # \b garantit que l'on ne remplace que le mot entier
        self.raw.gsub!(/\bjesusbys\b/i, 'JesusBYS')
      end
    end
  end
end
