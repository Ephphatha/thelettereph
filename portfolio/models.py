from django.db import models
from markupfield.fields import MarkupField
from autoslug import AutoSlugField
from taggit.managers import TaggableManager

class Project(models.Model):
  title = models.CharField(max_length=200)
  slug = AutoSlugField(populate_from='title', unique=True)
  blurb = models.TextField(help_text='Will be shown in the list view and prepended to the description. Use plain text only and limit text length to one paragraph.')
  description = MarkupField(default_markup_type='markdown', blank=True)
  thumbnail = models.ImageField(upload_to='images/', blank=True, default="thumb.png")
  binary = models.FileField(upload_to='files/', blank=True)
  source = models.URLField(blank=True)
  documentation = models.URLField(blank=True)
  tags = TaggableManager()
  start_date = models.DateField()
  update_date = models.DateField(blank=True, null=True)

  def __unicode__(self):
    return self.title

  class Meta:
    ordering = ['title']

def screenshot_file_name(instance, filename):
  return '/'.join(['images', instance.project.slug, filename])

class Screenshot(models.Model):
  project = models.ForeignKey(Project)
  title = models.CharField(max_length=200)
  image = models.ImageField(upload_to=screenshot_file_name)
  description = models.TextField(blank=True)

  def __unicode__(self):
    return self.title

  class Meta:
    ordering = ['title']
