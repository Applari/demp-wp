<?php


// ** MySQL settings ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wpaplrwp');

/** MySQL database username */
define('DB_USER', 'wpdbuser');

/** MySQL database password */
define('DB_PASSWORD', 'oa5Keequ6roa');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

define('AUTH_KEY',         'Vors0WbYlTp,0u,@psa+TG8}<=PF5We?I{%KW-aCEN&H+myti^B28Cda|wgk.HGX');
define('SECURE_AUTH_KEY',  '-fRukwK~V?z*eV.Ot,9lBo|+7*4&]w$-_p&a$0%3&[y)!+i ~>#whyjihY5^L@Nq');
define('LOGGED_IN_KEY',    '`G&%16+y9(x:3X9x>R~%mrg)J}^Rxi!ZqtrvEs0NG=:*QW5RK-a`rw*;*K:V;Gg|');
define('NONCE_KEY',        '}dQ^{E`>Y>_>F8S8yW&i(LLQe7eI[chzs>ycbznL[X.!1aYPKR2}tvoF3OT@u~-#');
define('AUTH_SALT',        '<49Vig9%WA&i};Q8iaX<K~lR%(b~p>oY-AHvbyynFF]+.}9!UpDr;Pc%_N-Bd4ES');
define('SECURE_AUTH_SALT', '~`=4(1|-,PqY[%a|dl4$tl$`5eoG](I7z0+8(dFxnw@j^+O-ZFk[$LT^0HwL7<--');
define('LOGGED_IN_SALT',   'D [ra`gNf%(c$ohji,=|S5|.b6<EfaGz2)x.f#+(-BGRXRc4:%h@V^~+9JEC|>o=');
define('NONCE_SALT',       's2$<H,_}kUS-#qog(nE:Z6+c?u#{;,yK{S6&8,YlW9H2$-Efn[crDeUR,lhI,B$/');


$table_prefix = 'saehe';





/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
