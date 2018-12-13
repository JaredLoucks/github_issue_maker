module GithubIssueMaker
  def set_config_variables
    @instance_details = GITHUB_ISSUE_MAKER_CONFIG[:instance_details]
    @github_details = GITHUB_ISSUE_MAKER_CONFIG[:github_details]
    @s3_details = GITHUB_ISSUE_MAKER_CONFIG[:s3_details]
  end

  def create_github_issue!
    set_config_variables

    s3 = Aws::S3::Client.new
    s3_body = Base64.decode64(self.send(@instance_details[:screenshot_column]).gsub(/^data:image\/\w+;base64,/, ''))
    s3.put_object(bucket: @s3_details[:bucket], acl: 'public-read', key: file_name, body: s3_body,
                  content_type: 'image/png')

    github = Github.new oauth_token: @github_details[:access_token]
    file_name = "#{SecureRandom.hex}/issue.png"
    issue = github.issues.create(user: @github_details[:user], repo: @github_details[:repo],
                                 title: @github_details[:issue_title], body: github_issue_body(file_name),
                                 labels: @github_details[:labels])
    issue[:html_url]
  end

  def github_issue_body(screenshot_url)
    body = []
    body << "# Description \n #{description_section}"
    body << "# User \n #{user_section}"
    body << "# Url \n #{url_section}"
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
end