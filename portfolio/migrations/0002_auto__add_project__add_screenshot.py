# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'Project'
        db.create_table(u'portfolio_project', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('title', self.gf('django.db.models.fields.CharField')(max_length=200)),
            ('slug', self.gf('django.db.models.fields.SlugField')(max_length=50)),
            ('blurb', self.gf('django.db.models.fields.TextField')()),
            ('description', self.gf('markupfield.fields.MarkupField')(rendered_field=True, blank=True)),
            ('description_markup_type', self.gf('django.db.models.fields.CharField')(default='markdown', max_length=30, blank=True)),
            ('thumbnail', self.gf('django.db.models.fields.files.ImageField')(max_length=100, blank=True)),
            ('_description_rendered', self.gf('django.db.models.fields.TextField')()),
            ('file', self.gf('django.db.models.fields.files.FileField')(max_length=100, blank=True)),
            ('source', self.gf('django.db.models.fields.URLField')(max_length=200, blank=True)),
            ('start_date', self.gf('django.db.models.fields.DateField')()),
            ('end_date', self.gf('django.db.models.fields.DateField')(null=True, blank=True)),
        ))
        db.send_create_signal(u'portfolio', ['Project'])

        # Adding model 'Screenshot'
        db.create_table(u'portfolio_screenshot', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('project', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['portfolio.Project'])),
            ('title', self.gf('django.db.models.fields.CharField')(max_length=200)),
            ('image', self.gf('django.db.models.fields.files.ImageField')(max_length=100)),
            ('description', self.gf('django.db.models.fields.TextField')(blank=True)),
        ))
        db.send_create_signal(u'portfolio', ['Screenshot'])


    def backwards(self, orm):
        # Deleting model 'Project'
        db.delete_table(u'portfolio_project')

        # Deleting model 'Screenshot'
        db.delete_table(u'portfolio_screenshot')


    models = {
        u'portfolio.project': {
            'Meta': {'ordering': "['title']", 'object_name': 'Project'},
            '_description_rendered': ('django.db.models.fields.TextField', [], {}),
            'blurb': ('django.db.models.fields.TextField', [], {}),
            'description': ('markupfield.fields.MarkupField', [], {'rendered_field': 'True', 'blank': 'True'}),
            'description_markup_type': ('django.db.models.fields.CharField', [], {'default': "'markdown'", 'max_length': '30', 'blank': 'True'}),
            'end_date': ('django.db.models.fields.DateField', [], {'null': 'True', 'blank': 'True'}),
            'file': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'blank': 'True'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'slug': ('django.db.models.fields.SlugField', [], {'max_length': '50'}),
            'source': ('django.db.models.fields.URLField', [], {'max_length': '200', 'blank': 'True'}),
            'start_date': ('django.db.models.fields.DateField', [], {}),
            'thumbnail': ('django.db.models.fields.files.ImageField', [], {'max_length': '100', 'blank': 'True'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '200'})
        },
        u'portfolio.screenshot': {
            'Meta': {'ordering': "['title']", 'object_name': 'Screenshot'},
            'description': ('django.db.models.fields.TextField', [], {'blank': 'True'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image': ('django.db.models.fields.files.ImageField', [], {'max_length': '100'}),
            'project': ('django.db.models.fields.related.ForeignKey', [], {'to': u"orm['portfolio.Project']"}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '200'})
        }
    }

    complete_apps = ['portfolio']