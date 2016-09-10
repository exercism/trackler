require_relative '../test_helper'
require 'trackler'

class TrackTest < Minitest::Test
  def assert_archive_contains(filenames, zip)
    files = []
    Zip::InputStream.open(zip) do |io|
      while (entry = io.get_next_entry)
        files << entry.name
      end
    end
    assert_equal filenames.sort, files.sort
  end

  def test_default_track
    track = Trackler::Track.new('fake', FIXTURE_PATH)

    assert track.exists?, "track 'fake' not found"
    assert track.active?, "track 'fake' inactive"
    assert_equal "Fake", track.language
    assert_equal "https://github.com/exercism/xfake", track.repository
    assert_equal 5, track.checklist_issue
    assert_equal nil, track.gitter

    problems = %w(hello-world one two three)
    assert_equal problems, track.problems
    assert_equal ["apple"], track.foregone
    assert_equal ["dog"], track.deprecated
    assert_equal problems, track.implementations.map {|implementation|
      implementation.problem.slug
    }

    slugs = %w(hello-world one two three apple dog)
    assert_equal slugs, track.slugs

    # default test pattern
    assert_equal(/test/i, track.test_pattern)
  end

  def test_img
    track = Trackler::Track.new('fake', FIXTURE_PATH)

    img = track.img('img/icon.png')
    assert img.exists?, "track icon fake.png cannot be found in img dir"
    assert_equal :png, img.type
    assert_equal FIXTURE_PATH + "/tracks/fake/img/icon.png", img.path

    img = track.img('docs/img/test.png')
    assert img.exists?, "image test.png cannot be found in docs dir"
    assert_equal :png, img.type
    assert_equal FIXTURE_PATH + "/tracks/fake/docs/img/test.png", img.path

    img = track.img('docs/img/nope.png')
    refute img.exists?, "should not have a nope.png"
  end

  def test_docs
    track = Trackler::Track.new('fake', FIXTURE_PATH)

    expected = {
      "about" => "Language Information\n",
      "installation" => "Installing\n",
      "tests" => "Running\n",
      "learning" => "Learning Fake!\n",
      "resources" => "",
    }
    assert_equal expected, track.docs
  end

  def test_doc_format
    assert_equal "org", Trackler::Track.new('fake', FIXTURE_PATH).doc_format
    assert_equal "md", Trackler::Track.new('fruit', FIXTURE_PATH).doc_format
    assert_equal "md", Trackler::Track.new('jewels', FIXTURE_PATH).doc_format # no docs dir
  end

  def test_track_with_gitter_room
    track = Trackler::Track.new('fruit', FIXTURE_PATH)
    assert_equal 'xfruit', track.gitter
  end

  def test_track_with_default_checklist_issue
    track = Trackler::Track.new('fruit', FIXTURE_PATH)
    assert_equal 1, track.checklist_issue
  end

  def test_custom_test_pattern
    track = Trackler::Track.new('fruit', FIXTURE_PATH)
    assert_equal(/\.tst$/, track.test_pattern)
  end

  def test_unknown_track
    refute Trackler::Track.new('nope', FIXTURE_PATH).exists?, "unexpected track 'nope'"
  end

  def test_icon_path
    subject = Trackler::Track.new('fake', FIXTURE_PATH)
    expected = FIXTURE_PATH + '/tracks/fake/img/icon.png'
    assert_equal expected, subject.icon_path
  end

  def test_icon_path_nonexisting
    subject = Trackler::Track.new('noicon', FIXTURE_PATH)
    expected = nil
    assert_equal expected, subject.icon_path
  end

  def test_global_files
    track = Trackler::Track.new('animal', FIXTURE_PATH)
    files = ["some-vendored-library", "sub-global/other-some-vendor"]
    assert_archive_contains files, track.global_zip
  end
end
