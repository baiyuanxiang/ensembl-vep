# Copyright [2016] EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;

use Test::More;
use Test::Exception;
use FindBin qw($Bin);

use lib $Bin;
use VEPTestingConfig;
my $test_cfg = VEPTestingConfig->new();

my $cfg_hash = $test_cfg->base_testing_cfg;
$cfg_hash->{input_file} = $test_cfg->{test_vcf};

## BASIC TESTS
##############

# use test
use_ok('Bio::EnsEMBL::VEP::Haplo::Runner');

my $runner = Bio::EnsEMBL::VEP::Haplo::Runner->new($cfg_hash);
ok($runner, 'new is defined');

is(ref($runner), 'Bio::EnsEMBL::VEP::Haplo::Runner', 'check class');

is($runner->param('haplo'), 1, 'haplo param set by new');



## METHOD TESTS
###############

is_deeply(
  $runner->get_all_AnnotationSources(),
  [
    bless( {
      '_config' => $runner->config,
      'cache_region_size' => 1000000,
      'dir' => $test_cfg->{cache_dir},
      'serializer_type' => undef,
      'gencode_basic' => undef,
      'source_type' => 'ensembl',
      'all_refseq' => undef,
      'polyphen' => undef,
      'sift' => undef,
      'everything' => undef,
      'info' => {
        'polyphen' => '2.2.2',
        'sift' => 'sift5.2.2',
        'COSMIC' => '75',
        'ESP' => '20141103',
        'gencode' => 'GENCODE 24',
        'HGMD-PUBLIC' => '20154',
        'genebuild' => '2014-07',
        'regbuild' => '13.0',
        'assembly' => 'GRCh38.p5',
        'dbSNP' => '146',
        'ClinVar' => '201601'
      },
      'valid_chromosomes' => [21, 'LRG_485'],
    }, 'Bio::EnsEMBL::VEP::Haplo::AnnotationSource::Cache::Transcript' )
  ],
  'get_all_AnnotationSources'
);

# setup_db_connection should return silently in offline mode
ok(!$runner->setup_db_connection(), 'setup_db_connection');

is_deeply($runner->get_valid_chromosomes, [21, 'LRG_485'], 'get_valid_chromosomes');

is_deeply($runner->get_Parser, bless({
  '_config' => $runner->config,
  'file' => $test_cfg->{test_vcf},
  'file_bak' => $test_cfg->{test_vcf},
  'line_number' => 0,
  'check_ref' => undef,
  'chr' => undef,
  'dont_skip' => undef,
  'valid_chromosomes' => {21 => 1, LRG_485 => 1},
  'minimal' => undef,
  'lrg' => undef,
  'delimiter' => "\t",
  'process_ref_homs' => undef,
  'allow_non_variant' => undef,
  'gp' => undef,
  'individual' => undef,
  'phased' => undef,
}, 'Bio::EnsEMBL::VEP::Haplo::Parser::VCF' ), 'get_Parser');

my $t = $runner->get_TranscriptTree;
delete $t->{trees};

is_deeply(
  $runner->get_TranscriptTree,
  bless( {
    '_config' => $runner->config,
    'valid_chromosomes' => {
      '21' => 1,
      'LRG_485' => 1
    },
  }, 'Bio::EnsEMBL::VEP::Haplo::TranscriptTree' ),
  'get_TranscriptTree'
);

is_deeply($runner->get_InputBuffer, bless({
  '_config' => $runner->config,
  'parser' => $runner->get_Parser,
  'buffer_size' => $runner->param('buffer_size'),
  'minimal' => undef,
  'transcript_tree' => $runner->get_TranscriptTree,
}, 'Bio::EnsEMBL::Haplo::VEP::InputBuffer' ), 'get_InputBuffer');

ok($runner->init, 'init');

# my $info = $runner->get_output_header_info;
# ok($info->{time}, 'get_output_header_info - time');
# ok($info->{api_version} =~ /^\d+$/, 'get_output_header_info - api_version');
# ok($info->{vep_version} =~ /^\d+$/, 'get_output_header_info - vep_version');
# is(ref($info->{input_headers}), 'ARRAY', 'get_output_header_info - input_headers');

# is_deeply(
#   $info->{version_data}, 
#   {
#     'polyphen' => '2.2.2',
#     'sift' => 'sift5.2.2',
#     'COSMIC' => '75',
#     'ESP' => '20141103',
#     'gencode' => 'GENCODE 24',
#     'HGMD-PUBLIC' => '20154',
#     'genebuild' => '2014-07',
#     'regbuild' => '13.0',
#     'assembly' => 'GRCh38.p5',
#     'dbSNP' => '146',
#     'ClinVar' => '201601'
#   },
#   'get_output_header_info - version_data'
# );

# is_deeply($runner->get_OutputFactory, bless( {
#   '_config' => $runner->config,
#   'uniprot' => undef,
#   'xref_refseq' => undef,
#   'numbers' => undef,
#   'polyphen_analysis' => 'humvar',
#   'pick_allele' => undef,
#   'coding_only' => undef,
#   'refseq' => undef,
#   'no_escape' => undef,
#   'total_length' => undef,
#   'per_gene' => undef,
#   'sift' => undef,
#   'appris' => undef,
#   'canonical' => undef,
#   'symbol' => undef,
#   'pick_order' => $runner->param('pick_order'),
#   'pick' => undef,
#   'no_intergenic' => undef,
#   'gene_phenotype' => undef,
#   'flag_pick_allele' => undef,
#   'process_ref_homs' => undef,
#   'af_esp' => undef,
#   'most_severe' => undef,
#   'terms' => 'SO',
#   'flag_pick_allele_gene' => undef,
#   'flag_pick' => undef,
#   'summary' => undef,
#   'af_exac' => undef,
#   'polyphen' => undef,
#   'af' => undef,
#   'biotype' => undef,
#   'protein' => undef,
#   'domains' => undef,
#   'pick_allele_gene' => undef,
#   'variant_class' => undef,
#   'ccds' => undef,
#   'hgvs' => undef,
#   'merged' => undef,
#   'af_1kg' => undef,
#   'tsl' => undef,
#   'pubmed' => undef,
#   'header_info' => $info,
#   'plugins' => [],
#   'no_stats' => undef,
#   'allele_number' => undef,
# }, 'Bio::EnsEMBL::VEP::OutputFactory::VEP_output' ), 'get_OutputFactory');

# ok($runner->init, 'init');

# is_deeply(
#   $runner->_buffer_to_output($runner->get_InputBuffer),
#   [
#     join("\t", qw(
#       rs142513484
#       21:25585733
#       T
#       ENSG00000154719
#       ENST00000307301
#       Transcript
#       3_prime_UTR_variant
#       1122
#       - - - - -
#       IMPACT=MODIFIER;STRAND=-1
#     )),
#     join("\t", qw(
#       rs142513484
#       21:25585733
#       T
#       ENSG00000154719
#       ENST00000352957
#       Transcript
#       missense_variant
#       1033
#       991
#       331
#       A/T
#       Gca/Aca
#       -
#       IMPACT=MODERATE;STRAND=-1
#     )),
#     join("\t", qw(
#       rs142513484
#       21:25585733
#       T
#       ENSG00000260583
#       ENST00000567517
#       Transcript
#       upstream_gene_variant
#       -
#       -
#       -
#       -
#       -
#       -
#       IMPACT=MODIFIER;DISTANCE=2407;STRAND=-1
#     )),
#   ],
#   '_buffer_to_output'
# );

# $runner = Bio::EnsEMBL::VEP::Runner->new($cfg_hash);

# is(
#   $runner->next_output_line, 
#   join("\t", qw(
#     rs142513484
#     21:25585733
#     T
#     ENSG00000154719
#     ENST00000307301
#     Transcript
#     3_prime_UTR_variant
#     1122
#     - - - - -
#     IMPACT=MODIFIER;STRAND=-1
#   )),
#   'next_output_line'
# );

# # output file
# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, output_file => $test_cfg->{user_file}.'.out'});
# is(ref($runner->get_output_file_handle), 'FileHandle', 'get_output_file_handle - ref');

# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, output_file => $test_cfg->{user_file}.'.out'});
# throws_ok {$runner->get_output_file_handle} qr/Output file .+ already exists/, 'get_output_file_handle - fail on existing';

# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, output_file => 'stdout'});
# is($runner->get_output_file_handle, '*main::STDOUT', 'get_output_file_handle - stdout');

# unlink($test_cfg->{user_file}.'.out');

# # stats file
# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, output_file => $test_cfg->{user_file}.'.out'});
# is(ref($runner->get_stats_file_handle('txt')), 'FileHandle', 'get_stats_file_handle - txt ref');
# ok(-e $test_cfg->{user_file}.'.out_summary.txt', 'get_stats_file_handle - txt file exists');

# throws_ok {$runner->get_stats_file_handle('txt')} qr/Stats file .+ already exists/, 'get_stats_file_handle - fail on existing';
# unlink($test_cfg->{user_file}.'.out_summary.txt');

# is(ref($runner->get_stats_file_handle('html')), 'FileHandle', 'get_stats_file_handle - html ref');
# ok(-e $test_cfg->{user_file}.'.out_summary.html', 'get_stats_file_handle - html file exists');
# unlink($test_cfg->{user_file}.'.out_summary.html');

# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, stats_file => $test_cfg->{user_file}.'.stats'});
# $runner->get_stats_file_handle('txt');
# ok(-e $test_cfg->{user_file}.'.stats.txt', 'get_stats_file_handle - extension handling 1');
# unlink($test_cfg->{user_file}.'.stats.txt');

# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, stats_file => $test_cfg->{user_file}.'.txt'});
# $runner->get_stats_file_handle('txt');
# ok(-e $test_cfg->{user_file}.'.txt', 'get_stats_file_handle - extension handling 2');

# $runner->get_stats_file_handle('html');
# ok(-e $test_cfg->{user_file}.'.html', 'get_stats_file_handle - extension handling 3');
# unlink($test_cfg->{user_file}.'.txt');
# unlink($test_cfg->{user_file}.'.html');

# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, stats_file => $test_cfg->{user_file}.'_stats'});
# $runner->get_stats_file_handle('txt');
# ok(-e $test_cfg->{user_file}.'_stats.txt', 'get_stats_file_handle - extension handling 4');
# unlink($test_cfg->{user_file}.'_stats.txt');



# # run method
# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   output_file => $test_cfg->{user_file}.'.out',
#   stats_file => $test_cfg->{user_file}.'.txt',
#   stats_html => 1,
#   stats_text => 1,
# });

# ok($runner->run, 'run - ok');

# open IN, $test_cfg->{user_file}.'.out';
# my @tmp_lines = <IN>;
# is(scalar @tmp_lines, 38, 'run - count lines');

# is_deeply(
#   [grep {!/^\#/} @tmp_lines],
#   [
#     "rs142513484\t21:25585733\tT\tENSG00000154719\tENST00000307301\tTranscript\t3_prime_UTR_variant\t1122\t-\t-\t-\t-\t-\tIMPACT=MODIFIER;STRAND=-1\n",
#     "rs142513484\t21:25585733\tT\tENSG00000154719\tENST00000352957\tTranscript\tmissense_variant\t1033\t991\t331\tA/T\tGca/Aca\t-\tIMPACT=MODERATE;STRAND=-1\n",
#     "rs142513484\t21:25585733\tT\tENSG00000260583\tENST00000567517\tTranscript\tupstream_gene_variant\t-\t-\t-\t-\t-\t-\tIMPACT=MODIFIER;DISTANCE=2407;STRAND=-1\n",
#   ],
#   'run - lines content'
# );

# ok(-e $test_cfg->{user_file}.'.txt', 'dump_stats - text exists');
# ok(-e $test_cfg->{user_file}.'.html', 'dump_stats - html exists');

# unlink($test_cfg->{user_file}.'.txt');
# unlink($test_cfg->{user_file}.'.html');
# unlink($test_cfg->{user_file}.'.out');


# # plugins
# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, plugin => ['TestPlugin'], quiet => 1});

# is_deeply(
#   $runner->get_all_Plugins,
#   [
#     bless( {
#       'params' => [],
#       'variant_feature_types' => [
#         'VariationFeature'
#       ],
#       'feature_types' => [
#         'Transcript'
#       ],
#       'version' => '2.3',
#       'config' => $runner->config,
#     }, 'TestPlugin' )
#   ],
#   'get_all_Plugins'
# );

# # warning_msg prints to STDERR
# no warnings 'once';
# open(SAVE, ">&STDERR") or die "Can't save STDERR\n"; 

# my $tmp;
# close STDERR;
# open STDERR, '>', \$tmp;

# # plugin doesn't compile
# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   warning_file => 'STDERR',
#   plugin => ['TestPluginNoCompile'],
#   quiet => 1,
# });
# ok($runner->get_all_Plugins, 'get_all_Plugins - failed to compile');
# ok($tmp =~ /Failed to compile plugin/, 'get_all_Plugins - failed to compile message');

# # $runner = Bio::EnsEMBL::VEP::Runner->new({
# #   %$cfg_hash,
# #   warning_file => 'STDERR',
# #   plugin => ['TestPluginNoCompile'],
# #   quiet => 1,
# #   safe => 1
# # });
# # throws_ok {$runner->get_all_Plugins} qr/Failed to compile plugin/, 'get_all_Plugins - failed to compile safe die';


# # plugin new method fails
# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   warning_file => 'STDERR',
#   plugin => ['TestPluginNewFails'],
#   quiet => 1,
# });
# ok($runner->get_all_Plugins, 'get_all_Plugins - new fails');
# ok($tmp =~ /Failed to instantiate plugin/, 'get_all_Plugins - new fails message');

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   warning_file => 'STDERR',
#   plugin => ['TestPluginNewFails'],
#   quiet => 1,
#   safe => 1
# });
# throws_ok {$runner->get_all_Plugins} qr/Failed to instantiate plugin/, 'get_all_Plugins - new fails safe die';


# # plugin missing required methods
# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   warning_file => 'STDERR',
#   plugin => ['TestPluginNoMethods'],
#   quiet => 1,
# });
# ok($runner->get_all_Plugins, 'get_all_Plugins - missing methods');
# ok($tmp =~ /required method/, 'get_all_Plugins - missing methods message');

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   warning_file => 'STDERR',
#   plugin => ['TestPluginNoMethods'],
#   quiet => 1,
#   safe => 1
# });
# throws_ok {$runner->get_all_Plugins} qr/required method/, 'get_all_Plugins - missing methods safe die';


# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, plugin => ['TestPluginRegFeat'], quiet => 1});
# is($runner->param('regulatory'), undef, 'get_all_Plugins - switch on regulatory 1');
# $runner->get_all_Plugins;
# is($runner->param('regulatory'), 1, 'get_all_Plugins - switch on regulatory 2');



# # restore STDERR
# open(STDERR, ">&SAVE") or die "Can't restore STDERR\n";



# ## post_setup_checks
# ####################

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   dir => $test_cfg->{cache_root_dir}.'/sereal',
#   hgvs => 1,
#   offline => 1,
# });
# throws_ok {$runner->post_setup_checks} qr/Cannot generate HGVS coordinates in offline mode/, 'post_setup_checks - hgvs + offline with no fasta';


# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   dir => $test_cfg->{cache_root_dir}.'/sereal',
#   check_ref => 1,
#   offline => 1,
# });
# throws_ok {$runner->post_setup_checks} qr/Cannot check reference sequences/, 'post_setup_checks - check_ref + offline with no fasta';

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   lrg => 1,
#   offline => 1,
# });
# throws_ok {$runner->post_setup_checks} qr/Cannot map to LRGs in offline mode/, 'post_setup_checks - lrg + offline';

# ## status_msg tests require we mess with STDOUT
# ###############################################

# # status_msg prints to STDOUT
# no warnings 'once';
# open(SAVE, ">&STDOUT") or die "Can't save STDOUT\n"; 

# close STDOUT;
# open STDOUT, '>', \$tmp;

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   dir => $test_cfg->{cache_root_dir}.'/sereal',
#   everything => 1,
#   offline => 1,
# });
# is($runner->param('hgvs'), 1, 'post_setup_checks - everything + offline with no fasta disables hgvs - before');
# $runner->post_setup_checks();
# is($runner->param('hgvs'), 0, 'post_setup_checks - everything + offline with no fasta disables hgvs - after');
# ok($tmp =~ /Disabling --hgvs/, 'post_setup_checks - status_msg for above');
# $tmp = '';

# foreach my $flag(qw(lrg check_sv check_ref hgvs)) {
#   $runner = Bio::EnsEMBL::VEP::Runner->new({
#     %$cfg_hash,
#     dir => $test_cfg->{cache_root_dir}.'/sereal',
#     $flag => 1,
#     cache => 1,
#     offline => 0,
#     database => 0,
#   });
#   $runner->post_setup_checks();
#   ok($tmp =~ /Database will be accessed when using --$flag/, 'post_setup_checks - info - '.$flag);
#   $tmp = '';
# }

# open(STDOUT, ">&SAVE") or die "Can't restore STDOUT\n";



# ## FORKING
# ##########

# my $input = [
#   [qw(21 25585733 rs142513484 C T . . . GT 0|0)],
#   [qw(21 25587701 rs187353664 T C . . . GT 0|0)],
#   [qw(21 25587758 rs116645811 G A . . . GT 0|0)],
#   [qw(21 25588859 rs199510789 C T . . . GT 0|0)],
# ];

# my $exp = [
#   'rs142513484 T ENST00000307301',
#   'rs142513484 T ENST00000352957',
#   'rs142513484 T ENST00000567517',
#   'rs187353664 C ENST00000307301',
#   'rs187353664 C ENST00000352957',
#   'rs187353664 C ENST00000567517',
#   'rs116645811 A ENST00000307301',
#   'rs116645811 A ENST00000352957',
#   'rs116645811 A ENST00000567517',
#   'rs199510789 T ENST00000307301',
#   'rs199510789 T ENST00000352957',
#   'rs199510789 T ENST00000419219'
# ];

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   offline => 1,
#   input_file => $test_cfg->create_input_file($input),
#   input_data => undef,
# });

# my @lines;
# while(my $line = $runner->next_output_line) {
#   my @split = split("\t", $line);
#   push @lines, join(" ", $split[0], $split[2], $split[4]);
# }

# is_deeply(
#   \@lines,
#   $exp,
#   'fork - check no fork'
# );

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   offline => 1,
#   input_file => $test_cfg->create_input_file($input),
#   input_data => undef,
#   fork => 2,
# });

# @lines = ();
# while(my $line = $runner->next_output_line) {
#   my @split = split("\t", $line);
#   push @lines, join(" ", $split[0], $split[2], $split[4]);
# }

# is_deeply(
#   \@lines,
#   $exp,
#   'fork - check fork (2)'
# );

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   offline => 1,
#   input_file => $test_cfg->create_input_file($input),
#   input_data => undef,
#   fork => 4,
# });

# @lines = ();
# while(my $line = $runner->next_output_line) {
#   my @split = split("\t", $line);
#   push @lines, join(" ", $split[0], $split[2], $split[4]);
# }

# is_deeply(
#   \@lines,
#   $exp,
#   'fork - check fork (4)'
# );


# # check whole input file
# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   offline => 1,
#   input_file => $test_cfg->{test_vcf},
#   input_data => undef,
# });

# $exp = [];
# while(my $line = $runner->next_output_line) {
#   push @$exp, $line;
# }

# # lets check stats aswell
# my $exp_stats = $runner->stats->{stats}->{counters};

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   offline => 1,
#   input_file => $test_cfg->{test_vcf},
#   input_data => undef,
#   fork => 2,
# });

# @lines = ();
# while(my $line = $runner->next_output_line) {
#   push @lines, $line;
# }

# is_deeply(
#   \@lines,
#   $exp,
#   'fork - full file check (2)'
# );

# is_deeply(
#   $runner->stats->{stats}->{counters},
#   $exp_stats,
#   'fork - stats (2)'
# );

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   offline => 1,
#   input_file => $test_cfg->{test_vcf},
#   input_data => undef,
#   fork => 4,
# });

# @lines = ();
# while(my $line = $runner->next_output_line) {
#   push @lines, $line;
# }

# is_deeply(
#   \@lines,
#   $exp,
#   'fork - full file check (4)'
# );

# is_deeply(
#   $runner->stats->{stats}->{counters},
#   $exp_stats,
#   'fork - stats (4)'
# );



# # check plugin cache data
# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   offline => 1,
#   input_file => $test_cfg->{test_vcf},
#   input_data => undef,
#   fork => 2,
#   quiet => 1,
#   plugin => ['TestPluginCache'],
# });

# while(my $line = $runner->next_output_line) {
#   1;
# }

# ok($runner->get_all_Plugins->[0]->{cache}, 'fork - plugin cache exists');
# is(scalar keys %{$runner->get_all_Plugins->[0]->{cache}}, 132, 'fork - plugin cache check');




# # warning_msg prints to STDERR
# no warnings 'once';
# open(SAVE, ">&STDERR") or die "Can't save STDERR\n"; 

# close STDERR;
# open STDERR, '>', \$tmp;

# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   offline => 1,
#   fork => 2,
# });

# $runner->param('warning_file', 'STDERR');

# $runner->{_test_warning} = 1;

# $runner->next_output_line();
# ok($tmp =~ 'TEST WARNING', 'fork - test warning');


# $runner = Bio::EnsEMBL::VEP::Runner->new({
#   %$cfg_hash,
#   offline => 1,
#   fork => 1,
# });
# $runner->param('warning_file', 'STDERR');
# $runner->{_test_die} = 1;

# throws_ok {$runner->next_output_line} qr/TEST DIE/, 'fork - test die';

# # restore STDERR
# open(STDERR, ">&SAVE") or die "Can't restore STDERR\n";



# ## run_rest
# ###########

# $runner = Bio::EnsEMBL::VEP::Runner->new({%$cfg_hash, format => 'vcf', delimiter => ' '});
# is_deeply(
#   $runner->run_rest('21 25585733 rs142513484 C T . . .'),
#   [
#     {
#       'input' => '21 25585733 rs142513484 C T . . .',
#       'assembly_name' => 'GRCh38',
#       'end' => 25585733,
#       'seq_region_name' => '21',
#       'strand' => 1,
#       'transcript_consequences' => [
#         {
#           'gene_id' => 'ENSG00000154719',
#           'variant_allele' => 'T',
#           'cdna_end' => 1122,
#           'consequence_terms' => [
#             '3_prime_UTR_variant'
#           ],
#           'strand' => -1,
#           'transcript_id' => 'ENST00000307301',
#           'cdna_start' => 1122,
#           'impact' => 'MODIFIER'
#         },
#         {
#           'gene_id' => 'ENSG00000154719',
#           'cds_start' => 991,
#           'variant_allele' => 'T',
#           'cdna_end' => 1033,
#           'protein_start' => 331,
#           'codons' => 'Gca/Aca',
#           'cds_end' => 991,
#           'consequence_terms' => [
#             'missense_variant'
#           ],
#           'protein_end' => 331,
#           'amino_acids' => 'A/T',
#           'strand' => -1,
#           'transcript_id' => 'ENST00000352957',
#           'cdna_start' => 1033,
#           'impact' => 'MODERATE'
#         },
#         {
#           'gene_id' => 'ENSG00000260583',
#           'variant_allele' => 'T',
#           'distance' => 2407,
#           'consequence_terms' => [
#             'upstream_gene_variant'
#           ],
#           'strand' => -1,
#           'transcript_id' => 'ENST00000567517',
#           'impact' => 'MODIFIER'
#         }
#       ],
#       'id' => 'rs142513484',
#       'most_severe_consequence' => 'missense_variant',
#       'allele_string' => 'C/T',
#       'start' => 25585733
#     }
#   ],
#   'run_rest'
# );



# ## DATABASE TESTS
# #################

# SKIP: {
#   my $db_cfg = $test_cfg->db_cfg;
#   my $can_use_db = $db_cfg && scalar keys %$db_cfg;

#   ## REMEMBER TO UPDATE THIS SKIP NUMBER IF YOU ADD MORE TESTS!!!!
#   skip 'No local database configured', 5 unless $can_use_db;

#   my $multi;

#   if($can_use_db) {
#     eval q{
#       use Bio::EnsEMBL::Test::TestUtils;
#       use Bio::EnsEMBL::Test::MultiTestDB;
#       1;
#     };

#     $multi = Bio::EnsEMBL::Test::MultiTestDB->new('homo_vepiens');
#   }
  
#   $runner = Bio::EnsEMBL::VEP::Runner->new({
#     %$cfg_hash,
#     %$db_cfg,
#     database => 1,
#     offline => 0,
#     species => 'homo_vepiens',
#   });

#   ok($runner->setup_db_connection(), 'db - setup_db_connection');

#   # check it is switching species using aliases
#   $runner = Bio::EnsEMBL::VEP::Runner->new({
#     %$cfg_hash,
#     %$db_cfg,
#     database => 1,
#     offline => 0,
#     species => 'human_vep',
#   });
#   $runner->setup_db_connection;

#   is($runner->species, 'homo_vepiens', 'db - species alias');

#   $info = $runner->get_output_header_info;

#   is($info->{db_host}, $db_cfg->{host}, 'get_output_header_info - db_host');
#   ok($info->{db_name} =~ /homo_vepiens_core.+/, 'get_output_header_info - db_name');
#   ok($info->{db_version}, 'get_output_header_info - db_version');
# };

done_testing();