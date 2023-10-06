# frozen_string_literal: true

class UserResumeDoc
  attr_reader :filename, :doc_template, :doc_element

  def initialize
    @doc_element = load_document('template-elements.docx')
    @doc_template = load_document('template.docx')
    @item_element = find_element('_item_')
    @text_element = find_element('_job_description_')
    @date_element = find_element('_date_')
    @job_element = @doc_element.bookmarks['job_title'].parent_paragraph
    @course_element = find_element('course_name')
    @contribution_title_element = find_element('project_name')
    @contribution_description_element = find_element('pr_description')
    @event_element = find_element('event_name')
  end

  def call(user)
    set_filename(user)

    I18n.with_locale(:en) do
      add_user_info(user)

      skills = user.skills.pluck(:title)
      mount_skill_section(skills)

      job_experiences = user.professional_experiences.ordered_by_start_date
      mount_professional_section(job_experiences)

      education_experiences = user.education_experiences.decorate
      mount_education_section(education_experiences)

      contribution_experiences = user.contributions
                                     .approved
                                     .order(created_at: :asc)
                                     .decorate
                                     .group_by(&:repository)
      mount_contribution_section(contribution_experiences)

      talk_experiences = user.talks.decorate
      mount_talk_section(talk_experiences)
    end

    I18n.with_locale(:pt_BR) { self }
  end

  def save
    @doc_template.save(@filename)
  end

  def to_string_io
    @doc_template.stream.read
  end

  private

  def load_document(filename)
    Docx::Document.open(filename)
  end

  def section(bookmark_name)
    @doc_template.bookmarks[bookmark_name].parent_paragraph
  end

  def add_user_info(user)
    @doc_template.paragraphs.each do |p|
      p.each_text_run do |tr|
        tr.substitute('user_name', user.name)
      end
    end
  end

  def mount_skill_section(skills)
    skill_section = section('skills')

    skills.each do |skill|
      skill_item = @item_element.copy
      substitute(skill_item, '_item_', skill)
      skill_item.insert_after skill_section
    end
  end

  def mount_professional_section(experiences)
    job_section = section('companies')

    experiences.each do |experience|
      title = @job_element.copy
      substitute(title, 'job_title', experience.position)
      substitute(title, 'company_name', experience.company)

      date_interval = "#{experience.decorate.start_date_month} - #{experience.decorate.end_date_month}"
      substitute(title, 'job_date', date_interval)

      description_paragraphs = experience.description.split("\r\n").reverse
      
      title.insert_after job_section

      description_paragraphs.each do |paragraph|
        description = @text_element.copy
        substitute(description, '_job_description_', paragraph)
        description.insert_after title
      end 
    end
  end

  def mount_education_section(experiences)
    education_section = section('education')

    experiences.each do |experience|
      title = @course_element.copy
      substitute(title, 'course_name', experience.course)
      substitute(title, 'institution_name', experience.institution)

      date_interval = "#{experience.start_year} - #{experience.end_year}"

      substitute(title, 'education_date', date_interval)

      title.insert_after education_section
    end
  end

  def mount_contribution_section(experiences)
    contribution_section = section('contribution')

    experiences.each do |repository, contributions|
      repository_name = repository.name
      title = @contribution_title_element.copy
      substitute(title, 'project_name', repository_name)

      title.insert_after contribution_section

      contributions.each do |contribution|
        pr_description = contribution.description
        description = @contribution_description_element.copy
        substitute(description, 'pr_description', pr_description)
        substitute(description, 'contribution_date', contribution.created_at)

        description.insert_after title
      end
    end
  end

  def mount_talk_section(experiences)
    talks_section = section('talks')

    experiences.each do |experience|
      title = @event_element.copy
      substitute(title, 'event_name', experience.event_name)
      substitute(title, 'talk_title', experience.talk_title)
      substitute(title, 'talk_date', experience.date)

      title.insert_after talks_section
    end
  end

  def find_element(placeholder)
    @doc_element.paragraphs.find { |p| p.to_s =~ /#{placeholder}/ }
  end

  def substitute(element, placeholder, text)
    element.text_runs.map { |tr| tr.substitute(placeholder, text) }
  end

  def set_filename(user)
    user_name = user.name.upcase.gsub(' ', '_')
    @filename = "#{user_name}_RESUME.docx"
  end

  def strip_extra_blank_space(string)
    string.gsub(/(\r\n)/, "\n\r")
  end
end
