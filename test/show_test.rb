class TestShow < TestDsl::TestCase
  describe 'args' do
    temporary_change_hash Byebug.settings, :argv, %w{foo bar}

    describe 'default behaviour' do
      it 'must show args' do
        enter 'show args'
        debug_file 'show'
        check_output_includes 'Argument list to give program being debugged ' \
                              'when it is started is "foo bar".'
      end
    end

    describe 'when BYEBUG_SCRIPT is defined' do
      temporary_change_const Byebug, 'BYEBUG_SCRIPT', 'bla'

      it 'must not show the first arg' do
        enter 'show args'
        debug_file 'show'
        check_output_includes 'Argument list to give program being debugged ' \
                              'when it is started is "bar".'
      end
    end
  end

  describe 'autolist' do
    it 'must show default value' do
      enter 'show autolist'
      debug_file 'show'
      check_output_includes 'autolist is on.'
    end
  end

  describe 'autoeval' do
    it 'must show default value' do
      enter 'show autoeval'
      debug_file 'show'
      check_output_includes 'autoeval is on.'
    end
  end

  describe 'autoreload' do
    it 'must show default value' do
      enter 'show autoreload'
      debug_file 'show'
      check_output_includes 'autoreload is on.'
    end
  end

  describe 'autoirb' do
    before { Byebug::IrbCommand.any_instance.stubs(:execute) }

    it 'must show default value' do
      enter 'show autoirb'
      debug_file 'show'
      check_output_includes 'autoirb is off.'
    end
  end

  describe 'basename' do
    it 'must show default value' do
      enter 'show basename'
      debug_file 'show'
      check_output_includes 'basename is off.'
    end
  end

  describe 'callstyle' do
    it 'must show default value' do
      enter 'show callstyle'
      debug_file 'show'
      check_output_includes 'Frame call-display style is long.'
    end
  end

  describe 'forcestep' do
    it 'must show default value' do
      enter 'show forcestep'
      debug_file 'show'
      check_output_includes 'force-stepping is off.'
    end
  end

  describe 'fullpath' do
    it 'must show default value' do
      enter 'show fullpath'
      debug_file 'show'
      check_output_includes 'Displaying frame\'s full file names is on.'
    end
  end

  describe 'linetrace' do
    it 'must show default value' do
      enter 'show linetrace'
      debug_file 'show'
      check_output_includes 'line tracing is off.'
    end
  end

  describe 'linetrace_plus' do
    it 'must show default value' do
      enter 'show linetrace_plus'
      debug_file 'show'
      check_output_includes 'line tracing style is different consecutive lines.'
    end
  end

  describe 'listsize' do
    it 'must show listsize' do
      enter 'show listsize'
      debug_file 'show'
      check_output_includes 'Number of source lines to list is 10.'
    end
  end

  describe 'stack_on_error' do
    it 'must show stack_on_error' do
      enter 'show stack_on_error'
      debug_file 'show'
      check_output_includes 'Displaying stack trace is off.'
    end
  end

  describe 'version' do
    it 'must show version' do
      enter 'show version'
      debug_file 'show'
      check_output_includes "Byebug #{Byebug::VERSION}"
    end
  end

  describe 'width' do
    let(:cols) { `stty size`.scan(/\d+/)[1].to_i }

    it 'must show default width' do
      enter 'show width'
      debug_file 'show'
      check_output_includes "width is #{cols}."
    end
  end

  describe 'unknown command' do
    it 'must show a message' do
      enter 'show bla'
      debug_file 'show'
      check_output_includes 'Unknown show command bla'
    end
  end

  describe 'history' do
    describe 'without arguments' do
      before do
        interface.history.file = 'hist_file.txt'
        interface.save_history = true
        interface.history.max_size = 25
        enter 'show history'
        debug_file 'show'
      end

      it 'must show history file' do
        check_output_includes(
          /filename: The command history file is "hist_file\.txt"/)
      end

      it 'must show history save setting' do
        check_output_includes(/save: Saving history is on\./)
      end

      it 'must show history length' do
        check_output_includes(/size: Byebug history's maximum size is 25/)
      end
    end

    describe 'with "filename" argument' do
      it 'must show history filename' do
        interface.history.file = 'hist_file.txt'
        enter 'show history filename'
        debug_file 'show'
        check_output_includes 'The command history file is "hist_file.txt"'
      end

      it 'must show history save setting' do
        interface.save_history = true
        enter 'show history save'
        debug_file 'show'
        check_output_includes 'Saving history is on.'
      end

      it "must show history's max size" do
        interface.history.max_size = 30
        enter 'show history size'
        debug_file 'show'
        check_output_includes "Byebug history's maximum size is 30"
      end
    end
  end

  describe 'commands' do
    temporary_change_const Readline, 'HISTORY', %w(aaa bbb ccc ddd)

    describe 'no readline support' do
      before { interface.save_history = false }

      it 'must not show records from readline' do
        enter 'show commands'
        debug_file 'show'
        check_output_includes 'No readline support'
      end
    end

    describe 'readline support' do
      before { interface.save_history = true }

      describe 'show records' do
        it 'displays last max_size records from readline history' do
          enter 'set history size 3', 'show commands'
          debug_file 'show'
          check_output_includes(/2  bbb\n    3  ccc\n    4  ddd/)
          check_output_doesnt_include(/1  aaa/)
        end
      end

      describe 'max records' do
        it 'displays whole history if max_size is bigger than Readline::HISTORY' do
          enter 'set history size 7', 'show commands'
          debug_file 'show'
          check_output_includes(/1  aaa\n    2  bbb\n    3  ccc\n    4  ddd/)
        end
      end

      describe 'with specified size' do
        it 'displays the specified number of entries most recent first' do
          enter 'show commands 2'
          debug_file 'show'
          check_output_includes(/3  ccc\n    4  ddd/)
          check_output_doesnt_include(/1  aaa\n    2  bbb/)
        end
      end
    end
  end

  describe 'Help' do
    it 'must show help when typing just "show"' do
      enter 'show', 'cont'
      debug_file 'show'
      check_output_includes(/List of "show" subcommands:/)
    end
  end
end
