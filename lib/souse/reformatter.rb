module Souse
  module Reformatter
    extend self

    def reformat_gherkin feature_jsons
      feature_jsons.each do |feature|
        feature["elements"].each do |scenario|
          if scenario["type"] =~ /outline/
            table = reformat_table scenario["examples"]
            reformat_outline feature["name"], scenario, table
          else
            reformat_scenario feature["name"], scenario
          end
        end
      end
    end

    def reformat_scenario feature, scenario
      {
        scenario["name"] => {
          "feature" => feature,
          "tags"    => (scenario["tags"] || []).map { |tag| tag["name"] },
          "steps"   => scenario["steps"].map { |step| step["keyword"] + step["name"] }
        }
      }
    end

    def reformat_table examples
      examples[0]["rows"].each_with_index.each_with_object({}) do |(row, row_i), table|
        if row_i.zero?
          row["cells"].each { |header| table[header] = [] }
        else
          row["cells"].each_with_index do |cell, cell_i|
            key = table.keys[cell_i]
            table[key] << cell
          end
        end
      end
    end

    def reformat_outline feature, outline, data
      data.first.size.times.to_a.each_with_object({}) do |i, scenarios|
        scenarios["#{outline['name']} #{i + 1}"] = {
          "feature" => feature,
          "tags"    => (outline["tags"] || []).map { |tag| tag["name"] },
          "steps"   => outline["steps"].map do |step|
            placeholder = step["name"][/<(.*)>/].gsub(/[<>]/, '') rescue nil
            corrected_step = step["name"].gsub(/<#{placeholder}>/, data[placeholder][i]) rescue step["name"]
            step["keyword"] + corrected_step
          end
        }
      end
    end
    
  end
end
