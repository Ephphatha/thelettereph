from django.conf.urls import patterns, url

from blog import views

urlpatterns = patterns('',
  url(r'^$', views.PostListView.as_view(), name='post-list'),
  url(r'^(?P<slug>[-_\w]+)/$', views.PostDetailView.as_view(), name='post-detail'),
)
