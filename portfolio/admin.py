from django.contrib import admin
from portfolio.models import Project, Screenshot

class ScreenshotInline(admin.StackedInline):
  model = Screenshot
  extra = 1

class ProjectAdmin(admin.ModelAdmin):
  list_display = ('title', 'start_date',)
  inlines = [ScreenshotInline]

admin.site.register(Project, ProjectAdmin)
