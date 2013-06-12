from django.contrib import admin
from blog.models import Post

class PostAdmin(admin.ModelAdmin):
  list_display = ('subject', 'date')

admin.site.register(Post, PostAdmin)
