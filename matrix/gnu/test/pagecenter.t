#!/usr/bin/perl

 
 
sub all {
    grep {
        $_->is_readable
    } map {
        $self->new_page($_->filename)
    } io($self->current->database_directory)->all_files;
}
 
sub all_ids_newest_first {
    my $path = $self->current->database_directory;
    # XXX Unix speed hack should be worked around for win32
    map {chomp; $_} `ls -1t $path`;
}
 
sub recent_by_count {
    my ($count) = @_;
    my @page_ids = $self->all_ids_newest_first;
    splice(@page_ids, $count)
      if @page_ids > $count;
    map { $self->new_page($_) } @page_ids;
}
 
sub all_since {
    my ($minutes) = @_;
    my @pages_since;
    for my $page_id ($self->all_ids_newest_first) {
        my $page = $self->new_page($page_id);
        last if $page->age_in_minutes > $minutes;
        next unless $page->is_readable;
        push @pages_since, $page;
    }   
    return @pages_since;
}
 
sub current_id {
    my $page_name = 
      $self->hub->cgi->page_name || 
      $self->hub->config->main_page;
    $self->name_to_id($page_name);
}
 
sub name_to_id {
    my $id = $self->uri_escape(shift);
}
 
sub name_to_title {
    (shift);
}
 
sub id_to_uri {
    (shift);
}
 
sub id_to_title {
    $self->uri_unescape(shift);
}
 
sub new_page {
    my $page_id = shift;
    return if length $page_id > 255;
    my $page = $self->page_class->new(id => $page_id);
    $page->metadata($self->new_metadata($page_id));
    return $page;
}
 
sub new_from_name {
    my $page_name = shift;
    my $id = $self->name_to_id($page_name);
    my $page = $self->new_page($id);
    return unless $page;
    $page->title($self->name_to_title($page_name));
    return $page;
}
 
sub new_metadata {
    my $page_id = shift or die;
    $self->meta_class->new(id => $page_id);
}
 
 
sub all {
    return (
        page_uri => $self->uri,
        page_title => $self->title,
    );
}
 
sub database_directory {
    $self->hub->config->database_directory;
}
 
sub content {
    return $self->{content} = shift if @_;
    return $self->{content} if defined $self->{content};
    $self->load_content;
    return $self->{content};
}
 
sub metadata {
    return $self->{metadata} = shift if @_;
    $self->{metadata} ||= 
      $self->meta_class->new(id => $self->id);
    return $self->{metadata} if $self->{metadata}->loaded;
    $self->load_metadata;
    return $self->{metadata};
}
 
sub update {
    $self->metadata->update($self);
    return $self;
}
 
sub kwiki_link {
    my ($label) = @_;
    my $page_uri = $self->uri;
    $label = $self->title
      unless defined $label;
    return $label unless $self->is_readable;
    my $script = $self->hub->config->script_name;
    my $class = $self->active
      ? '' : ' class="empty"';
    qq(<a href="$script?$page_uri"$class>$label</a>);
}
 
sub edit_by_link {
    my $user_name = $self->metadata->edit_by || 'UnknownUser';
    $user_name = $self->hub->config->user_default_name
      if $user_name =~ /[^$ALPHANUM]/;
    my $page = $self->hub->pages->new_page($user_name);
    $page->kwiki_link;
}
 
sub edit_time {
    my $edit_time = $self->metadata->edit_unixtime ||
                    $self->modified_time;
    return $self->hub->have_plugin('time_zone')
    ? $self->hub->time_zone->format($edit_time)
    : $self->format_time($edit_time);
}
 
sub format_time {
    my $unix_time = shift;
    my $formatted = scalar gmtime $unix_time;
    $formatted .= ' GMT'
      unless $formatted =~ /GMT$/;
    return $formatted;
}
 
#XXX This is a bad idea. io is the IO::All constructor. Making it into a
# method is problematic
sub io {
    Kwiki::io($self->file_path)->file;
}
 
sub modified_time {
    $self->io->mtime || 0;
}
 
sub age {
    $self->age_in_minutes;
}
 
sub age_in_minutes {
    $self->age_in_seconds / 60;
}
 
sub age_in_seconds {
    return $self->{age_in_seconds} = shift if @_;
    return $self->{age_in_seconds} if defined $self->{age_in_seconds};
    my $path = $self->database_directory;
    my $page_id = $self->id;
    return $self->{age_in_seconds} = (time - $self->modified_time);
}
 
sub to_html {
    my $content = @_ ? shift : $self->content; 
    $self->hub->formatter->text_to_html($content);
}
 
sub history {
    $self->hub->archive->history($self);
}
 
sub revision_number {
    $self->hub->archive->revision_number($self);
}
 
sub revision_numbers {
    $self->hub->archive->revision_numbers($self, @_);
}
 
package Kwiki::PageMeta;

 
 
sub sort_order {
    qw(edit_by edit_time edit_unixtime edit_address)
}
 
sub file_path {
    join '/', $self->plugin_directory, $self->id;
}
 
sub load {
    $self->loaded(1);
    my $file_path = $self->file_path;
    return unless -f $file_path;
    my $hash = $self->parse_yaml_file($file_path);
    $self->from_hash($hash);
}
 
sub update {
    my $page = shift;
    $self->edit_by($self->hub->users->current->name);
    my $unixtime = time;
    $self->edit_time(scalar gmtime($unixtime));
    $self->edit_unixtime($unixtime);
    $self->edit_address($self->get_edit_address);
    return $self;
}
 
sub get_edit_address {
    $ENV{HTTP_X_FORWARDED_FOR} ||
    $ENV{REMOTE_ADDR} ||
    '';
}
 
sub store {
    my $file_path = $self->file_path;
    my $hash = $self->to_hash;
    $self->print_yaml_file($file_path, $hash);
}
 
package Kwiki::Pages;
 
__DATA__
Show 23 lines of Pod
__!database/HomePage__
=== Welcome to Your New Kwiki!
 
You have successfully installed a new Kwiki. Now you should /edit this page/ and start adding NewPages. For help on Kwiki syntax and other Kwiki issues, visit http://www.kwiki.org/?KwikiHelpIndex.
 
If this installation looks more mundane than you had expected after visiting Kwiki sites like http://www.kwiki.org, you need to install some *Kwiki plugins*. Some of the basic plugins you might want are:
 
* Kwiki::!RecentChanges
* Kwiki::Search
* Kwiki::!UserPreferences
* Kwiki::!UserName
* Kwiki::Archive::Rcs
* Kwiki::Revisions
 
These plugin modules are available on [CPAN http://search.cpan.org/search?query=kwiki&mode=dist]. Visit http://www.kwiki.org/?KwikiPluginInstallation to learn more about installing plugins.
 
--[http://www.kwiki.org/?BrianIngerson Brian Ingerson]
