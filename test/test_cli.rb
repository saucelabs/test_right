require 'test_helper'
require 'tmpdir'

class TestCLI < Test::Unit::TestCase
  def test_fails_with_no_selectors_file
    assert_raises Test::Right::ConfigurationError do
      cli = Test::Right::CLI.new
      cli.load_selectors
    end
  end

  def test_parses_selectors
    Dir.mktmpdir do |path|
      Dir.chdir(path)
      make_selectors_file

      cli = Test::Right::CLI.new
      cli.load_selectors

      assert !cli.selectors.widgets.empty?, "No widget found from generated selectors.rb"
    end
  end

  def test_fails_with_no_widgets_dir
    assert_raises Test::Right::ConfigurationError do
      cli = Test::Right::CLI.new
      cli.load_widgets
    end
  end

  def test_finds_widgets
    Dir.mktmpdir do |path|
      Dir.chdir(path)
      make_widget

      cli = Test::Right::CLI.new
      cli.load_widgets
      
      assert !cli.widgets.empty?, "No widgets loaded"
    end
  end

  def test_avoids_non_widgets
    Dir.mktmpdir do |path|
      Dir.chdir(path)
      make_widget("foo.rb.zzz")

      cli = Test::Right::CLI.new
      cli.load_widgets

      assert cli.widgets.empty?, "Loaded something that's not a widget: #{cli.widgets}"
    end
  end

  def test_finds_features
    Dir.mktmpdir do |path|
      Dir.chdir(path)
      make_feature

      cli = Test::Right::CLI.new
      cli.load_features
      
      assert !cli.features.empty?, "No features loaded"
    end
  end

  def test_start
    in_new_dir do
      make_selectors_file
      make_widget
      make_feature

      cli = Test::Right::CLI.new
      cli.start([])
      assert true # Start didn't cause any errors
    end
  end

  private

  def in_new_dir
    Dir.mktmpdir do |path|
      Dir.chdir(path)
      yield
    end
  end

  def make_selectors_file
    File.open "selectors.rb", "wb" do |f|
      f.print <<-SELECTORS
        widget "Foo" do
          field :foo, :id => 'bar'
        end
      SELECTORS
    end
  end

  def make_widget(filename="foo_widget.rb")
    Dir.mkdir("widgets")

    File.open "widgets/#{filename}", 'wb' do |f|
      f.print <<-WIDGET
        class FooWidget < Test::Right::Widget
        end
      WIDGET
    end
  end

  def make_feature
    Dir.mkdir("features")

    File.open "features/login.rb", 'wb' do |f|
      f.print <<-WIDGET
        class LoginFeature < Test::Right::Feature
        end
      WIDGET
    end
  end
end