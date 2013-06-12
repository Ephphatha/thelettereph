from django.db import models
from markupfield.fields import MarkupField
from autoslug import AutoSlugField

class Post(models.Model):
  subject = models.CharField(max_length = 200)
  slug = AutoSlugField(populate_from='subject', unique=True)
  body = MarkupField(default_markup_type='markdown')
  date = models.DateField()
  
  def __unicode__(self):
    return self.subject

  class Meta:
    ordering = ['date']
