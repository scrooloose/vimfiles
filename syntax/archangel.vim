" Vim syntax file
" Language:		archangel (a Ruby dsl)
" Maintainer:		Martin Grenfell <martin_grenfell at msn dot com>
" ----------------------------------------------------------------------------
syn match builderMethod '\<\(uid\|gid\|port\|base_path\|default_root\|mime_types\|pid_file\|error_log\|access_log\)\>' "nginx builder
syn match builderMethod '\<\(uid\|gid\)\>' "mongrel builder
syn match builderMethod '\<\(hostnames\|aliases\|path\|port\|profile\|template\|fair\|unfair\|mongrels\)\>' "site builder
syn match builderMethod '\<\(profile\|load_balancer\|upstream\|site\)\>'
hi link builderMethod keyword

hi link highBuilderMethod preproc

