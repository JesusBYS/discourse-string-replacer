# name: discourse-string-replacer
# about: Remplace littéralement \u003e par > dans tous les posts (Humain, API, IA)
# version: 0.4
# authors: JesusBYS
# url: https://github.com/JesusBYS/discourse-string-replacer

after_initialize do
  module ::PrewriteStringReplacer
    def self.apply(str)
      return str if str.blank?

      # 1) literal sequence "\u003e" -> ">"
      out = str.gsub('\\u003e', '>')

      # 2) jesusbys (any case) -> JesusBYS
      # out = out.gsub(/jesusbys/i, 'JesusBYS')

      out
    end
  end

  # --- Posts: create + edit (before DB write) ---
  Post.class_eval do
    before_validation do
      next unless SiteSetting.prewrite_string_replacer_enabled
      self.raw = ::PrewriteStringReplacer.apply(self.raw)
    end
  end

  # --- PostRevisions: if raw is stored there too (depending on flows) ---
  if defined?(PostRevision)
    PostRevision.class_eval do
      before_validation do
        next unless SiteSetting.prewrite_string_replacer_enabled
        if self.modifications.is_a?(Hash)
          # Sometimes "raw" is inside modifications
          if self.modifications["raw"].is_a?(Array) && self.modifications["raw"][1].is_a?(String)
            self.modifications["raw"][1] = ::PrewriteStringReplacer.apply(self.modifications["raw"][1])
          end
        end
      end
    end
  end

  # --- Translations stored as custom fields (common pattern for translators/AI features) ---
  # We apply to ANY custom field value that is a String AND looks like translation-related,
  # so translations created/updated by AI also get normalized before DB write.
  if defined?(PostCustomField)
    PostCustomField.class_eval do
      before_validation do
        next unless SiteSetting.prewrite_string_replacer_enabled
        next unless self.value.is_a?(String)

        name = self.name.to_s
        looks_like_translation =
          name.include?("translation") ||
          name.include?("translated") ||
          name.include?("ai_") ||
          name.include?("llm")

        next unless looks_like_translation

        self.value = ::PrewriteStringReplacer.apply(self.value)
      end
    end
  end
end
