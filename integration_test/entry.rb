require 'test/unit'
require 'open-uri'
require 'openssl'
require 'json'

# Usage: https://qiita.com/repeatedly/items/727b08599d87af7fa671
# Assertions: https://test-unit.github.io/test-unit/ja/Test/Unit/Assertions.html

REMOTE_SERVER='https://127.0.0.1:8443'

def get_urls(path:, urls: 0, max: 100)
  res = open(
    "#{REMOTE_SERVER}#{path}?urls=#{urls}&max=#{max}",
    :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
  ).read
  return JSON.load(res)
end

def get_urls_wprest(path:, page: 1, limit: 100)
  res = open(
    "#{REMOTE_SERVER}/wp-json/shifter/v1/urls/#{path}?page=#{page}&limit=#{limit}",
    :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
  ).read
  return JSON.load(res)
end

def count_by(items, type, value)
  result = items['items'].select { |i| i[type] == value }
  return result.size
end


class TestRootPath < Test::Unit::TestCase
  description '/?urls=0&max=100 and ?page=1&limit=100'
  items = get_urls(path: '/')
  rest_items = get_urls_wprest(path: '/')

  data(
    'all_counts' => [items['count'], 100],
    'start' => [items['start'], 0],
    'end' => [items['end'], 100],
    'finished' => [items['finished'], false],
    'home' => [count_by(items, 'link_type', 'home'), 1],
    '404' => [count_by(items, 'link_type', '404'), 1],
    'feed' => [count_by(items, 'link_type', 'feed'), 5],
  )

  def test_root_path_first(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  # for rest-api
  data(
    'all_counts' => [rest_items['count'], 100],
    'start' => [rest_items['start'], 0],
    'end' => [rest_items['end'], 100],
    'finished' => [rest_items['finished'], false],
    'home' => [count_by(rest_items, 'link_type', 'home'), 1],
    '404' => [count_by(rest_items, 'link_type', '404'), 1],
    'feed' => [count_by(rest_items, 'link_type', 'feed'), 5],
  )

  def test_rest_root_path_first(data)
    expected, actual = data
    assert_equal(expected, actual)
  end


  description '/?urls=4&max=100 and ?page=5&limit=100'
  items = get_urls(path: '/', urls: 4)
  rest_items = get_urls_wprest(path: '/', page: 5)

  data(
    'all_counts' => [items['count'], 23],
    'start' => [items['start'], 400],
    'end' => [items['end'], 500],
    'finished' => [items['finished'], true],
  )

  def test_root_path_end(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  # for rest-api
  data(
    'all_counts' => [rest_items['count'], 23],
    'start' => [rest_items['start'], 400],
    'end' => [rest_items['end'], 500],
    'finished' => [rest_items['finished'], true],
  )

  def test_rest_root_path_end(data)
    expected, actual = data
    assert_equal(expected, actual)
  end


  description 'alldata: /?urls=0&max=500 and ?page=1&limit=500'
  items = get_urls(path: '/', urls: 0, max: 500)
  rest_items = get_urls_wprest(path: '/', page: 1, limit: 500)

  data(
    'all_counts' => [items['count'], 423],
    'start' => [items['start'], 0],
    'end' => [items['end'], 500],
    'finished' => [items['finished'], true],
    'home' => [count_by(items, 'link_type', 'home'), 1],
    '404' => [count_by(items, 'link_type', '404'), 1],
    'feed' => [count_by(items, 'link_type', 'feed'), 5],
    'permalink' => [count_by(items, 'link_type', 'permalink'), 58],
    'amphtml' => [count_by(items, 'link_type', 'amphtml'), 38],
    'term_link' => [count_by(items, 'link_type', 'term_link'), 199],
    'archive_link' => [count_by(items, 'link_type', 'archive_link'), 86],
    'redirection' => [count_by(items, 'link_type', 'redirection'), 13],
  )

  def test_root_path_all(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  # for rest-api
  data(
    'all_counts' => [rest_items['count'], 423],
    'start' => [rest_items['start'], 0],
    'end' => [rest_items['end'], 500],
    'finished' => [rest_items['finished'], true],
    'home' => [count_by(rest_items, 'link_type', 'home'), 1],
    '404' => [count_by(rest_items, 'link_type', '404'), 1],
    'feed' => [count_by(rest_items, 'link_type', 'feed'), 5],
    'permalink' => [count_by(rest_items, 'link_type', 'permalink'), 58],
    'amphtml' => [count_by(rest_items, 'link_type', 'amphtml'), 38],
    'term_link' => [count_by(rest_items, 'link_type', 'term_link'), 199],
    'archive_link' => [count_by(rest_items, 'link_type', 'archive_link'), 86],
    'redirection' => [count_by(rest_items, 'link_type', 'redirection'), 13],
  )

  def test_rest_root_path_all(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end


class TestRedirectLimit < Test::Unit::TestCase
  # Limit case: redirection only items
  description '/?urls=41&max=10'
  items = get_urls(path: '/', urls: 41, max: 10)
  rest_items = get_urls_wprest(path: '/', page: 42, limit: 10)

  data(
    'all_counts' => [items['count'], 10],
    'finished' => [items['finished'], false],
    'redirection' => [count_by(items, 'link_type', 'redirection'), 10],
  )

  def test_redirection_counts_pre_end(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  # for rest-api
  data(
    'all_counts' => [rest_items['count'], 10],
    'finished' => [rest_items['finished'], false],
    'redirection' => [count_by(rest_items, 'link_type', 'redirection'), 10],
  )

  def test_rest_redirection_counts_pre_end(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  # Limit case: redirection only items
  description '/?urls=42&max=10'
  items = get_urls(path: '/', urls: 42, max: 10)
  rest_items = get_urls_wprest(path: '/', page: 43, limit: 10)

  data(
    'all_counts' => [items['count'], 3],
    'finished' => [items['finished'], true],
    'redirection' => [count_by(items, 'link_type', 'redirection'), 3],
  )

  def test_redirection_counts_end(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  # for rest-api
  data(
    'all_counts' => [rest_items['count'], 3],
    'finished' => [rest_items['finished'], true],
    'redirection' => [count_by(rest_items, 'link_type', 'redirection'), 3],
  )

  def test_rest_redirection_counts_end(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end


class TestCategoryPagenates < Test::Unit::TestCase
  description 'Category pagenation'
  items = get_urls(path: '/category/markup/')
  rest_items = get_urls_wprest(path: '/category/markup/')

  data(
    'all_counts' => [items['count'], 2],
    'finished' => [items['finished'], true],
    'paginate_link' => [count_by(items, 'link_type', 'paginate_link'), 2],
  )

  def test_category_case1(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  # for rest-api
  data(
    'all_counts' => [rest_items['count'], 2],
    'finished' => [rest_items['finished'], true],
    'paginate_link' => [count_by(rest_items, 'link_type', 'paginate_link'), 2],
  )

  def test_rest_category_case1(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end


class TestArchivePagenates < Test::Unit::TestCase
  description 'Archive pagenation'
  items = get_urls(path: '/2010/')
  rest_items = get_urls_wprest(path: '/2010/')

  data(
    'all_counts' => [items['count'], 7],
    'finished' => [items['finished'], true],
    'paginate_link' => [count_by(items, 'link_type', 'paginate_link'), 7],
  )

  def test_archive_case1(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  data(
    'all_counts' => [rest_items['count'], 7],
    'finished' => [rest_items['finished'], true],
    'paginate_link' => [count_by(rest_items, 'link_type', 'paginate_link'), 7],
  )

  def test_rest_archive_case1(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end


class TestPostHasNextPage < Test::Unit::TestCase
  description 'has Nextpage'
  items = get_urls(path: '/2012/01/template-paginated/')
  rest_items = get_urls_wprest(path: '/2012/01/template-paginated/')

  data(
    'all_counts' => [items['count'], 2],
    'finished' => [items['finished'], true],
    'paginate_link' => [count_by(items, 'link_type', 'paginate_link'), 2],
  )

  def test_nexpage_case1(data)
    expected, actual = data
    assert_equal(expected, actual)
  end

  data(
    'all_counts' => [rest_items['count'], 2],
    'finished' => [rest_items['finished'], true],
    'paginate_link' => [count_by(rest_items, 'link_type', 'paginate_link'), 2],
  )

  def test_rest_nexpage_case1(data)
    expected, actual = data
    assert_equal(expected, actual)
  end
end
