require 'yaml'

class script_executer
  config = YAML.load_file('acid.yml');
  #puts config.inspect;
  setup_scripts = config['setup'];
  environment_variables = config['env'];
  execute_scripts = config['exec'];

  setup_scripts.each { |i|
    puts system(i);
  }
  environment_variables.each { |i|
    puts system(i);
  }
  execute_scripts.each { |i|
    puts system(i);
  }
end