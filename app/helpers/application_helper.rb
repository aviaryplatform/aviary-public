# ApplicationHelper
module ApplicationHelper
  include ApplicationHelperExtended
  require 'securerandom'

  def organization_layout?
    nil
  end

  def collection_feed(_collection_id)
    nil
  end

  def iscached?
    false
  end

  def path_for_request(digital_object_id)
    "/deliverableUnits/#{digital_object_id}?includeNestedLinks=true"
  end

  def stopwords
    %w(a an and are as at be but by for if in into is it no not of on or such that the their then there these they this to was will with)
  end

  def count_em(string, substring)
    substring = substring.delete(')').delete('(')
    string.present? && substring.present? ? string.to_s.scan(/#{Regexp.escape(substring)}/i).count : 0
  end

  # pass path to get current page active link
  def active_class(link_path)
    current_page?(link_path) ? 'active' : ''
  end

  # pass array of paths to get current page active link
  def active_class_multiple(array)
    array.include?(request.path) ? 'active' : ''
  end

  def clean_uri(query)
    query.to_s.gsub(%r{[/?!*'();:@&=+\]\[$,/?%# ]}, '')
  rescue StandardError
    ''
  end

  # states array for CA and US + None
  def available_states
    none = { none: 'None' }
    divider = { divider: '----------------' }
    canada = CS.states(:ca)
    us = CS.states(:us)

    results = none.merge!(divider)
    results.merge!(us)
    results.merge!(canada)
    results
  end

  def time_to_duration(seconds)
    Time.at(seconds.to_f).utc.strftime('%H:%M:%S')
  rescue StandardError
    '00:00:00'
  end

  # Get the logo of a current organization
  def organization_logo
    main_logo = 'homepage/main-logo.png'
    if current_organization && current_organization.logo_image.present?
      current_organization.logo_image.url
    else
      main_logo
    end
  end

  # Registering Presents
  def present(model, presenter_class = nil)
    klass = presenter_class || "#{model.class}Presenter".constantize
    presenter = klass.new(model, self)
    yield(presenter) if block_given?
  end

  def random_number
    random = Time.now.to_i
    random.to_s + rand(10_000).to_s
  end

  # Languages array iso-639-1
  def iso_639_1_languages
    languages_array = languages_array_simple
    languages_array.first.map { |l| [l[1], l[0]] }
  end

  def languages_array_simple
    languages_array = ['ab' => 'Abkhazian', 'aa' => 'Afar', 'af' => 'Afrikaans', 'ak' => 'Akan', 'sq' => 'Albanian', 'am' => 'Amharic', 'ar' => 'Arabic', 'an' => 'Aragonese',
                       'hy' => 'Armenian', 'as' => 'Assamese', 'av' => 'Avaric', 'ae' => 'Avestan', 'ay' => 'Aymara', 'az' => 'Azerbaijani', 'bm' => 'Bambara', 'ba' => 'Bashkir',
                       'eu' => 'Basque', 'be' => 'Belarusian', 'bn' => 'Bengali', 'bh' => 'Bihari languages',
                       'bi' => 'Bislama', 'bs' => 'Bosnian', 'br' => 'Breton', 'bg' => 'Bulgarian', 'my' => 'Burmese',
                       'ca' => 'Catalan, Valencian', 'km' => 'Central Khmer', 'ch' => 'Chamorro', 'ce' => 'Chechen', 'ny' => 'Chichewa, Chewa, Nyanja', 'zh' => 'Chinese', 'zh-TW' => 'Chinese (Traditional)',
                       'cu' => 'Church Slavonic, Old Bulgarian, Old Church Slavonic', 'cv' => 'Chuvash', 'kw' => 'Cornish', 'co' => 'Corsican', 'cr' => 'Cree',
                       'hr' => 'Croatian', 'cs' => 'Czech', 'da' => 'Danish', 'dv' => 'Divehi, Dhivehi, Maldivian', 'nl' => 'Dutch, Flemish', 'dz' => 'Dzongkha',
                       'en' => 'English', 'eo' => 'Esperanto', 'et' => 'Estonian', 'ee' => 'Ewe',
                       'fo' => 'Faroese', 'fj' => 'Fijian', 'fi' => 'Finnish', 'fr' => 'French', 'ff' => 'Fulah', 'gd' => 'Gaelic, Scottish Gaelic', 'gl' => 'Galician',
                       'lg' => 'Ganda', 'ka' => 'Georgian', 'de' => 'German', 'ki' => 'Gikuyu, Kikuyu', 'el' => 'Greek (Modern)', 'kl' => 'Greenlandic, Kalaallisut', 'gn' => 'Guarani',
                       'gu' => 'Gujarati', 'ht' => 'Haitian, Haitian Creole', 'ha' => 'Hausa',
                       'he' => 'Hebrew', 'hz' => 'Herero', 'hi' => 'Hindi', 'ho' => 'Hiri Motu', 'hu' => 'Hungarian',
                       'is' => 'Icelandic', 'io' => 'Ido', 'ig' => 'Igbo', 'id' => 'Indonesian',
                       'ia' => 'Interlingua (International Auxiliary Language Association)', 'ie' => 'Interlingue',
                       'iu' => 'Inuktitut', 'ik' => 'Inupiaq', 'ga' => 'Irish', 'it' => 'Italian', 'ja' => 'Japanese',
                       'jv' => 'Javanese', 'kn' => 'Kannada', 'kr' => 'Kanuri', 'ks' => 'Kashmiri', 'kk' => 'Kazakh',
                       'rw' => 'Kinyarwanda', 'kv' => 'Komi', 'kg' => 'Kongo', 'ko' => 'Korean', 'kj' => 'Kwanyama, Kuanyama', 'ku' => 'Kurdish', 'ky' => 'Kyrgyz', 'lo' => 'Lao',
                       'la' => 'Latin', 'lv' => 'Latvian', 'lb' => 'Letzeburgesch, Luxembourgish', 'li' => 'Limburgish, Limburgan, Limburger', 'ln' => 'Lingala', 'lt' => 'Lithuanian',
                       'lu' => 'Luba-Katanga', 'mk' => 'Macedonian', 'mg' => 'Malagasy', 'ms' => 'Malay', 'ml' => 'Malayalam',
                       'mt' => 'Maltese', 'gv' => 'Manx', 'mi' => 'Maori', 'mr' => 'Marathi', 'mh' => 'Marshallese',
                       'ro' => 'Moldovan, Moldavian, Romanian', 'mn' => 'Mongolian', 'na' => 'Nauru', 'nv' => 'Navajo, Navaho', 'nd' => 'Northern Ndebele', 'ng' => 'Ndonga',
                       'ne' => 'Nepali', 'se' => 'Northern Sami', 'no' => 'Norwegian', 'nb' => 'Norwegian Bokmål',
                       'nn' => 'Norwegian Nynorsk', 'ii' => 'Nuosu, Sichuan Yi', 'oc' => 'Occitan (post 1500)',
                       'oj' => 'Ojibwa', 'or' => 'Oriya', 'om' => 'Oromo', 'os' => 'Ossetian, Ossetic',
                       'pi' => 'Pali', 'pa' => 'Panjabi, Punjabi', 'ps' => 'Pashto, Pushto', 'fa' => 'Persian',
                       'pl' => 'Polish', 'pt' => 'Portuguese', 'qu' => 'Quechua', 'rm' => 'Romansh', 'rn' => 'Rundi',
                       'ru' => 'Russian', 'sm' => 'Samoan', 'sg' => 'Sango', 'sa' => 'Sanskrit',
                       'sc' => 'Sardinian', 'sr' => 'Serbian', 'sn' => 'Shona', 'sd' => 'Sindhi',
                       'si' => 'Sinhala, Sinhalese',
                       'sk' => 'Slovak', 'sl' => 'Slovenian', 'so' => 'Somali', 'st' => 'Sotho, Southern',
                       'nr' => 'South Ndebele',
                       'es' => 'Spanish', 'es-419' => 'Spanish (Latin America)', 'su' => 'Sundanese', 'sw' => 'Swahili', 'ss' => 'Swati',
                       'sv' => 'Swedish', 'tl' => 'Tagalog', 'ty' => 'Tahitian', 'tg' => 'Tajik', 'ta' => 'Tamil',
                       'tt' => 'Tatar', 'te' => 'Telugu', 'th' => 'Thai', 'bo' => 'Tibetan', 'ti' => 'Tigrinya',
                       'to' => 'Tonga (Tonga Islands)', 'ts' => 'Tsonga', 'tn' => 'Tswana', 'tr' => 'Turkish',
                       'tk' => 'Turkmen', 'tw' => 'Twi', 'ug' => 'Uighur, Uyghur', 'uk' => 'Ukrainian', 'ur' => 'Urdu', 'uz' => 'Uzbek', 've' => 'Venda', 'vi' => 'Vietnamese', 'vo' => 'Volap_k',
                       'wa' => 'Walloon', 'cy' => 'Welsh', 'fy' => 'Western Frisian', 'wo' => 'Wolof', 'xh' => 'Xhosa', 'yi' => 'Yiddish', 'yo' => 'Yoruba', 'za' => 'Zhuang, Chuang', 'zu' => 'Zulu']
    languages_array
  end

  def valid_json?(json)
    return false if json.nil?
    begin
      ruby_hash = JSON.parse(json)
      return ruby_hash
    rescue JSON::ParserError
      return false
    end
  end

  def storage_percent(current, allowed)
    100 * current / 1_048_576 / allowed
  end

  def resource_percent(current, allowed)
    100 * current / allowed
  end

  def compatibility_definition
    show_popup_compatibility = false
    if browser.chrome? && browser.version.to_i < 49
      show_popup_compatibility = true
    elsif browser.firefox? && browser.version.to_i < 48
      show_popup_compatibility = true
    elsif browser.ie? && browser.version.to_i < 11
      show_popup_compatibility = true
    elsif browser.opera? && browser.version.to_i < 36
      show_popup_compatibility = true
    elsif browser.safari? && browser.version.to_i < 6
      show_popup_compatibility = true
    end
    show_popup_compatibility
  end

  def current_user_is_org_owner_or_admin?
    org_users = current_user.organization_users.active.where(organization_id: current_organization.id) if current_user.present?
    org_users.present? && Role.org_owner_and_admin_id.include?(org_users.first.role_id)
  end

  def current_user_is_org_user?(organization)
    organization.present? && current_user.present? && current_user.organization_users.active.where(organization_id: organization.id).present?
  end

  def current_user_is_current_org_user?
    current_user.present? && current_user.organization_users.active.where(organization_id: current_organization.id).present?
  end

  def cost_pay_as_you_go(resources)
    per_resource = if resources <= 1000
                     15
                   elsif resources <= 4500
                     9
                   elsif resources <= 17_500
                     4
                   elsif resources <= 50_000
                     2
                   else
                     1
                   end
    resources * per_resource.to_f / 100
  end

  def url_image(url)
    url.present? ? "background-size:cover;background-image: url(#{image_url url})" : 'background-size:cover'
  end

  def generate_random_password
    OpenSSL::Digest::SHA256.new.hexdigest(SecureRandom.hex(8)) + '@AvIry'
  end

  def nunncenter_ohms_xsd
    'http://weareavp.com/nunncenter/ohms/ohms.xsd'
  end
end
