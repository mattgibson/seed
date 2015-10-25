module NavigationHelpers
  def path_to(page_name)

    case page_name

      when 'home'
        root_path

      else
        path_components = page_name.split(/\s+/) # 'new teaching resource'
        model_name = path_components.dup
        model_name.shift if %W{show edit new destroy update create index}.include?(model_name.first) # 'teaching resource'

        model = instance_variable_get "@#{model_name.join('_')}" # '@teaching_resource'

        begin
          self.send(path_components.push('path').join('_').to_sym, model) # 'new_teaching_resource_path'
        rescue Object => e
          raise "Can't find mapping from \"#{page_name}\" to a path:\n" +
                  "#{e.message}\n" +
                  "Now, go and add a mapping in #{__FILE__}"
        end
    end
  end
end

World(NavigationHelpers)