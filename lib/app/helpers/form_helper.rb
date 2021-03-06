require 'date'

module BootstrapDatepicker
  module FormHelper
    
    include ActionView::Helpers::JavaScriptHelper

    # Mehtod that generates datepicker input field inside a form
    def datepicker(object_name, method, options = {}, timepicker = false)
      input_tag =  BootstrapDatepicker::InstanceTag.new(object_name, method, self, options.delete(:object))
      dp_options, tf_options =  input_tag.baked_options(options)
      # tf_options[:value] = input_tag.format_date(tf_options[:value], String.new(dp_options[:dateFormat])) if  tf_options[:value] && !tf_options[:value].empty? && dp_options.has_key?(:dateFormat)
      html = input_tag.to_input_field_tag("text", tf_options)
      method = timepicker ? "datetimepicker" : "datepicker"
      # html += javascript_tag("jQuery(document).ready(function(){jQuery('##{input_tag.get_name_and_id["id"]}').#{method}(#{dp_options.to_json})});")
      html.html_safe
    end
    
  end

end

module BootstrapDatepicker::FormBuilder
  def datepicker(method, options = {})
    @template.datepicker(@object_name, method, objectify_options(options))
  end
  
  def datetime_picker(method, options = {})
    @template.datepicker(@object_name, method, objectify_options(options), true)
  end
end

class BootstrapDatepicker::InstanceTag < ActionView::Helpers::InstanceTag

  FORMAT_REPLACEMENTES = { "yy" => "%Y", "mm" => "%m", "dd" => "%d", "d" => "%-d", "m" => "%-m", "y" => "%y", "M" => "%b"}
  
  # Extending ActionView::Helpers::InstanceTag module to make Rails build the name and id
  # Just returns the options before generate the HTML in order to use the same id and name (see to_input_field_tag mehtod)
  
  def get_name_and_id(options = {})
    add_default_name_and_id(options)
    options
  end
  
  def available_datepicker_options
    [:format, :week_start, :view_mode, :min_view_mode]
  end

  def available_html_attributes
    [:class, :value, :maxlength]
  end
  
  def baked_options(options)
    tf_options = Hash.new
    
    options.each do |key, value|

      if available_datepicker_options.include? key
        new_key = ("data-" << key.to_s)
        tf_options[new_key] = value
      end

      if available_html_attributes.include? key
          tf_options[key.to_s] = value
      end

    end
    
    puts 'options' 
    puts options
    puts 'tf_options'
    puts tf_options

    return options, tf_options
  end
  
  def format_date(tb_formatted, format)
    new_format = translate_format(format)
    Date.parse(tb_formatted).strftime(new_format)
  end

  # Method that translates the datepicker date formats, defined in (http://docs.jquery.com/UI/Datepicker/formatDate)
  # to the ruby standard format (http://www.ruby-doc.org/core-1.9.3/Time.html#method-i-strftime).
  # This gem is not going to support all the options, just the most used.
  
  def translate_format(format)
    format.gsub!(/#{FORMAT_REPLACEMENTES.keys.join("|")}/) { |match| FORMAT_REPLACEMENTES[match] }
  end

end