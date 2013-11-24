package WWW::Kaufland;

use 5.014002;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use WWW::Kaufland ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


use LWP::UserAgent;
use XML::LibXML;
use XML::LibXSLT;


my $BASE = 'http://www.kaufland.de';
my $OFFERINGS = 'Home/01_Angebote/Aktuelle_Woche';
my @CATEGORIES = qw(
	01_Fleisch%2C_Gefluegel%2C_Wurst
);


sub new($$) {
	my $class = shift;
	my $store_id = shift;

	my $self = {
		store_id => $store_id,
		agent => LWP::UserAgent->new(),
	};

	return bless $self, $class;
}

sub get($$;$) {
	my $self = shift;
	my $path = shift;
	my $params = shift || {};

	my $url = "$BASE/$path?FilialID=" . $self->{store_id};
	$url .= join '&', map { $_ . '=' . $params->{$_} } keys $params;

	my $response = $self->{agent}->get($url);
	
	return $response;
}

sub get_offerings($$) {
	my $self = shift;
	my $category = shift;

	my $path = "$OFFERINGS/$CATEGORIES[$category]/index.jsp";
	my $response = $self->get($path);

	my $html = XML::LibXML->load_html(
		string => $response->decoded_content(),
		load_ext_dtd => 0,
		expand_entities => 1,
		recover => 2,
		suppress_warnings => 1,
		suppress_errors => 1
	);

	my $xslt = XML::LibXSLT->new();
	my $xsl = XML::LibXML->load_xml(IO => *DATA);
	my $stylesheet = $xslt->parse_stylesheet($xsl);

	my $offering = $stylesheet->transform($html);
	print $offering->toString(1);
}


1;

=head1 NAME

WWW::Kaufland - Perl extension for blah blah blah

=head1 SYNOPSIS 
  use WWW::Kaufland;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for WWW::Kaufland, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

8ward, E<lt>oxf5@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by 8ward

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

__DATA__
<?xml version="1.0"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:x="http://www.w3.org/1999/xhtml"
		version="1.0">
		<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>

	<xsl:template match="/">
		<xsl:element name="offering">
			<xsl:for-each select="/x:html//x:div[@id='articles']/x:table/x:tbody">
				<xsl:element name="article">
					<xsl:attribute name="name">
						<xsl:value-of select="x:tr[1]/x:td[0]/x:table[0]/x:tbody[0]/x:tr[0]/x:td[0]/x:div[0]"/>
					</xsl:attribute>
				</xsl:element>
				<xsl:element name="article">
					<xsl:attribute name="name">
						<xsl:value-of select="x:tr[1]/x:td[2]/x:table[0]/x:tbody[0]/x:tr[0]/x:td[0]/x:div[0]"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>

