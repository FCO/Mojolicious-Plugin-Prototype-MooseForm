package Mojolicious::Plugin::Prototype::MooseForm::TemplateData;
use Moose;
42

__DATA__

@@ moose_form.html.ep

<form>
   <% if($attributes) { =%>
      <%= include "class_attr_iterator", attributes => $attributes =%>
   <% } =%>
</form>

@@ class_attr_iterator.html.ep
<table>
% for my $attr(@$attributes) {
   <tr>
   %= include "attr_chooser", attr => $attr;
   </tr>
% }
</table>

@@ attr_chooser.html.ep
<td><%= $attr->{ name } =%></td>
