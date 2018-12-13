module GithubIssueMaker
  def create_github_issue!
    set_config_variables

    file_name = "#{SecureRandom.hex}/issue.png"
    create_s3_object(file_name)
    github = Github.new oauth_token: @github_details[:access_token]
    issue_body = github_issue_body(file_name)
    issue = github.issues.create(user: @github_details[:user], repo: @github_details[:repo], body: issue_body,
                                 title: @github_details[:issue_title], labels: @github_details[:labels])
    issue[:html_url]
  end

  def create_s3_object(file_name)
    s3 = Aws::S3::Client.new
    s3_body = decoded_issue_screenshot
    s3.put_object(bucket: @s3_details[:bucket], acl: 'public-read', key: file_name, body: s3_body, content_type: 'image/png')
  end

  def decoded_issue_screenshot
    screenshot = self.send(@instance_details[:screenshot_column])
    base_64_data_regex = /^data:image\/\w+;base64,/
    screenshot.gsub!(base_64_data_regex, '')
    Base64.decode64(screenshot)
  end

  def github_issue_body(screenshot_url)
    body = []
    body << "# Description \n #{description_section}"
    body << "# User \n #{user_section}"
    body << "# URL \n #{url_section}"
    body << "# Screenshot \n #{screenshot_section(screenshot_url)}"
    body << "# HEAD \n #{git_head_section}"
    body.join("\n \n")
  end

  def description_section
    self.send(@instance_details[:description_column])
  end

  def user_section
    user = self.send(@instance_details[:user_method])
    "#{user.try(:email) || user.try(:login)} - (#{user.try(:id)})"
  end

  def url_section
    self.send(@instance_details[:url_column])
  end

  def screenshot_section(screenshot_url)
    "![Issue](https://s3-#{@s3_details[:region]}.amazonaws.com/#{@s3_details[:bucket]}/#{screenshot_url})"
  end

  def git_head_section
    self.send(@instance_details[:git_hash_column])
  end

  private

  def set_config_variables
    @instance_details = GITHUB_ISSUE_MAKER_CONFIG[:instance_details]
    @github_details = GITHUB_ISSUE_MAKER_CONFIG[:github_details]
    @s3_details = GITHUB_ISSUE_MAKER_CONFIG[:s3_details]
  end
end