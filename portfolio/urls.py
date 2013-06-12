from django.conf.urls import patterns, url

from portfolio import views

urlpatterns = patterns('',
  url(r'^$', views.PortfolioView.as_view(), name='project-list'),
  url(r'^(?P<slug>[-_\w]+)/$', views.ProjectView.as_view(), name='project-detail'),
)
