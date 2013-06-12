from django.views.generic import ListView, DetailView

from portfolio.models import Project

class PortfolioView(ListView):
  model = Project
  template_name = 'portfolio/portfolio.html'
  context_object_name = 'project_list'
  
  def get_queryset(self):
    return Project.objects.order_by('title')

class ProjectView(DetailView):
  model = Project
  template_name = 'portfolio/project.html'
  context_object_name = 'project'
