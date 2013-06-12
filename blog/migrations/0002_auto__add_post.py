# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'Post'
        db.create_table(u'blog_post', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('subject', self.gf('django.db.models.fields.CharField')(max_length=200)),
            ('body', self.gf('markupfield.fields.MarkupField')(rendered_field=True)),
            ('body_markup_type', self.gf('django.db.models.fields.CharField')(default='markdown', max_length=30)),
            ('date', self.gf('django.db.models.fields.DateField')()),
            ('_body_rendered', self.gf('django.db.models.fields.TextField')()),
        ))
        db.send_create_signal(u'blog', ['Post'])


    def backwards(self, orm):
        # Deleting model 'Post'
        db.delete_table(u'blog_post')


    models = {
        u'blog.post': {
            'Meta': {'ordering': "['date']", 'object_name': 'Post'},
            '_body_rendered': ('django.db.models.fields.TextField', [], {}),
            'body': ('markupfield.fields.MarkupField', [], {'rendered_field': 'True'}),
            'body_markup_type': ('django.db.models.fields.CharField', [], {'default': "'markdown'", 'max_length': '30'}),
            'date': ('django.db.models.fields.DateField', [], {}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'subject': ('django.db.models.fields.CharField', [], {'max_length': '200'})
        }
    }

    complete_apps = ['blog']