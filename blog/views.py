from django.views.generic import ListView, DetailView
from django.utils import timezone

from blog.models import Post

class PostListView(ListView):
  model = Post
  context_object_name = 'post_list'
  
  def get_queryset(self):
    return Post.objects.filter(date__lte=timezone.now()).order_by('date')

class PostDetailView(DetailView):
  model = Post
  context_object_name = 'post'
  
  def get_queryset(self):
    return Post.objects.filter(date__lte=timezone.now())
