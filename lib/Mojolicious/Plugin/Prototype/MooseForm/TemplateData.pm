package Mojolicious::Plugin::Prototype::MooseForm::TemplateData;
use Moose;
42

__DATA__

@@ moose_form.html.ep

<form>
   <% if($class) { =%>
      <%= include "class_attr_iterator", class => $class =%>
   <% } =%>
</form>

@@ class_attr_iterator.html.ep
% my $meta = $class->meta;
% my @attrs = $meta->get_all_attributes;
<table>
% for my $attr(@attrs) {
   <tr>
   %= include "attr_chooser", attr => $attr;
   </tr>
% }
</table>

@@ attr_chooser.html.ep
<td><%= $attr->name =%></td>
