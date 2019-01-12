#! /usr/bin/perl -w
################################################################################
#
# Linux Installations Script
#
################################################################################

use strict;

use Cwd;
use File::Basename;
use File::Copy;
use File::Path qw(make_path);
use Getopt::Long;

################################################################################
#
# Einige Konfigurationskonstanten
#
################################################################################
my $IS_FOTOSCHAU_INSTALLER    = 0;
my $FILE_EULA				= "EULA.txt";
my $DOWNLOAD_SERVER			= "https://dls.photoprintit.com";
my $KEYACCID                  = '29227';
my $FULL_LOCALE               = 'es_ES';
my $CLIENTID                  = '38';
my $HPS_VER                   = '6.3.7';
my $VENDOR_NAME               = 'CEWE';
my $APPLICATION_NAME          = 'Taller CEWE';
my $INSTALL_DIR_DEFAULT       = 'Taller CEWE';
my $AFFILIATE_ID			= "";

my $PROGRAM_NAME_HPS          = 'Taller CEWE';
my $PROGRAM_NAME_FOTOSHOW     = 'VISTA DE FOTOS CEWE';
my $PROGRAM_NAME_FOTOIMPORTER = 'IMPORTADOR DE FOTOS CEWE';
my $PROGRAM_NAME_FACEDETECTION		= "facedetection";
my $PROGRAM_NAME_GPUPROBE			= "gpuprobe";
my $PROGRAM_NAME_ICONEXTRACTOR		= "IconExtractor";
my $PROGRAM_NAME_REGEDIT			= "regedit";
my $PROGRAM_NAME_QTWEBENGINEPROCESS	= "QtWebEngineProcess";
my $PROGRAM_NAME_INSTALLER			= "install.pl";
my $PROGRAM_NAME_UNINSTALLER		= "uninstall.pl";
my $PROGRAM_NAME_UPDATER			= "updater.pl";


################################################################################
#
# Texte
#
################################################################################
my @TRANSLATABLE;
my @TRANSLATABLE_ERRORS;

$TRANSLATABLE[0]  = "sí";
$TRANSLATABLE[1]  = "s";
$TRANSLATABLE[2]  = "no";
$TRANSLATABLE[3]  = "n";
$TRANSLATABLE[4]  = "Este script te servirá de ayuda en la instalación de '\033[1m%1\$s\033[0m' en tu equipo y te guiará paso a paso durante el proceso de instalación.\n\n";
$TRANSLATABLE[5]  = "Lee atentamente el EULA (End User License Agreement = licencia de usuario final). Después de leerlo,\ndeberás aceptar el EULA.\nDentro del mismo podrás navegar con las teclas de flecha, o salir del EULA pulsando la\ntecla “\033[1mq\033[0m�?.\n\nPara continuar, pulsa <INTRO>.";
$TRANSLATABLE[6]  = "¿Aceptas los términos de EULA?";
$TRANSLATABLE[7]  = "No puede instalarse \033[0m\033[1m'%1\$s'\033[0m en su equipo.\n\n\n";
$TRANSLATABLE[8]  = "\n¿Dónde deseas instalar '\033[1m%1\$s\033[0m'? [\033[1m%2\$s\033[0m] ";
$TRANSLATABLE[9]  = "¿Quieres continuar con la instalación y descargar los datos necesarios,\ncon un volumen total de %1\$.2f MB?";
$TRANSLATABLE[10] = "Descargando componentes “%1\$s�?... ";
$TRANSLATABLE[11] = "\nLos archivos necesarios se extraerán en el directorio de instalación.\n";
$TRANSLATABLE[12] = "\n¡Enhorabuena!\nLa instalación de \033[1m'%1\$s'\033[0m se ha finalizado con éxito.\nPara iniciarla ejecuta el archivo '%2\$s'.\n\n¡Que lo disfrutes!\n";
$TRANSLATABLE[13] = "¿Deseas volver a intentar descargar los archivos?";
$TRANSLATABLE[14] = "\t- %1\$-25s [%2\$.2f MB]\n";
$TRANSLATABLE[15] = "UNUSED";
$TRANSLATABLE[16] = "\nPara la instalación es necesario descargar los siguientes componentes:\n";
$TRANSLATABLE[17] = "\nLos componentes descargados no se han borrado tras la instalación\ny se encuentran en el directorio actual.\n";
$TRANSLATABLE[18] = "UNUSED";
$TRANSLATABLE[19] = "No existe el directorio indicado. ¿Deseas crear este directorio?";
$TRANSLATABLE[20] = "Opciones de la línea de comandos:\n   -h; --help\n   -i; --installDir=<DIR>\tEl directorio donde se instalará '%1\$s'.\n   -k; --keepPackages\t\tLos paquetes descargados no se eliminarán y se pueden utilizar para otra instalación.\n   -w; --workingDir=<DIR>\tEl directorio en el que se pueden archivar datos temporales.\n   -v; --verbose\t\tProporciona información durante la descarga.\n\nEl script busca los paquetes de instalación en directorio actual. Si no se encuentran los paquetes, serán descargados de Internet\nLos archivos temporales se guardarán en el directorio actual o en el directorio indicado con --workingDir. Si esto no es posible por falta de autorización, los archivos temporales se guardarán en /tmp.\n";
$TRANSLATABLE[21] = "Este script te será útil para desinstalar “\033[1m%1\$s\033[0m�?.\nAtención: Se van a borrar todos los datos del directorio “\033[1m%2\$s\033[0m�?. ¿Deseas continuar?";
$TRANSLATABLE[22] = "Descomprimiendo el paquete “%1\$s�?... ";
$TRANSLATABLE[23] = "listo\n";

$TRANSLATABLE_ERRORS[0]  = "Para las opciones de la línea de comandos '--installDir' y '--workingDir' es imprescindible indicar un directorio.\n";
$TRANSLATABLE_ERRORS[1]  = "Para una actualización es imprescindible indicar el directorio de instalación con '--installDir'.\n";
$TRANSLATABLE_ERRORS[2]  = "¡No existe el directorio de trabajo '%1\$s' indicado!\n";
$TRANSLATABLE_ERRORS[3]  = "¡No se puede identificar el directorio de trabajo!\n";
$TRANSLATABLE_ERRORS[4]  = "¡Para una correcta ejecución del script se requiere el programa '%1\$s'!\n";
$TRANSLATABLE_ERRORS[5]  = "¡No se puede encontrar el archivo '%1\$s'!\n";
$TRANSLATABLE_ERRORS[6]  = "\t¡No has aceptado los términos de EULA!\n\t%1\$s";
$TRANSLATABLE_ERRORS[7]  = "No es posible crear enlaces simbólicos en el directorio indicado. ¡Esta acción es imprescindible para la instalación de '%1\$s'!\n";
$TRANSLATABLE_ERRORS[8]  = "¡Se ha producido un fallo en la descarga del archivo '%1\$s'!\n";
$TRANSLATABLE_ERRORS[9]  = "¡No se puede abrir el archivo '%1\$s'!\n";
$TRANSLATABLE_ERRORS[10]  = "¡No se puede identificar la plataforma! 'uname -m' no envía 'i686' ni 'x86_64', sino '%1\$s'.\n";
$TRANSLATABLE_ERRORS[11]  = "¡No se ha podido descargar el archivo '%1\$s'!\n";
$TRANSLATABLE_ERRORS[12]  = "¡No se ha podido crear el directorio '%1\$s'!\n";
$TRANSLATABLE_ERRORS[13]  = "¡No se puede extraer el archivo '%1\$s'!\n";
$TRANSLATABLE_ERRORS[14]  = "¡No se ha podido copiar el archivo '%1\$s' en '%2\$s'!\n";
$TRANSLATABLE_ERRORS[15]  = "¡La suma de verificación del archivo '%1\$s' descargado no es correcta!\n";
$TRANSLATABLE_ERRORS[16]  = "¡El archivo '%1\$s' no se ha podido descargar en '%2\$s'!\n";
$TRANSLATABLE_ERRORS[17]  = "¡No se han podido identificar los paquetes necesarios!\n";
$TRANSLATABLE_ERRORS[18] = "%1\$s se ha instalado como “%2\$s�?. Por favor, inicia la desinstalación como usuario “%2\$s�?.\n";

my @ANSWER_YES_LIST	= ($TRANSLATABLE[0], $TRANSLATABLE[1]);
my @ANSWER_NO_LIST	= ($TRANSLATABLE[2], $TRANSLATABLE[3]);


################################################################################
#
# AB HIER SOLLTE NICHTS MEHR GEAENDERT WERDEN
# ===========================================
#
################################################################################


################################################################################
#
# Einige Konstanten
#
################################################################################
my $INDEX_FILE_PATH_ON_SERVER	= "/download/Data/$KEYACCID-$FULL_LOCALE/hps/$CLIENTID-index-$HPS_VER.txt";
my $MIME_TYPE					= "application/x-hps-$HPS_VER-mcf";
my $APP_ICON_FILE_NAME			= "hps-$KEYACCID-$HPS_VER";
my $PROGRAM_TO_START			= $PROGRAM_NAME_HPS;

if ($IS_FOTOSCHAU_INSTALLER == 1) {
	$INDEX_FILE_PATH_ON_SERVER	= "/cewe-myphotos/fs/$KEYACCID-$FULL_LOCALE/$CLIENTID-index-fotoplus-$HPS_VER.txt";
	$MIME_TYPE					= "application/x-cewe-fotoschau-$HPS_VER";
	$APP_ICON_FILE_NAME			= "cewe-fotoschau-$KEYACCID-$HPS_VER";
	$PROGRAM_TO_START			= $PROGRAM_NAME_FOTOSHOW;
}

my $DESKTOP_FILE_NAME			= "$APP_ICON_FILE_NAME.desktop";
my $DESKTOP_ICON_PATH			= "/Resources/keyaccount/32.ico";
my $SERVICES_XML_PATH			= "/Resources/services.xml";

my $INSTALL_DIR_DEF				= "$VENDOR_NAME/$INSTALL_DIR_DEFAULT";
my $LOG_FILE_DIR				= ".log";
my $INSTALL_LOG_FILE_NAME		= "install.log";
my @REQUIRED_PROGRAMMS			= ("unzip", "md5sum", "less", "wget", "uname");
my $DESKTOP_FILE_FORMAT			= "[Desktop Entry]\n".
									"Version=1.0\n".
									"Encoding=UTF-8\n".
									"Name=$APPLICATION_NAME\n".
									"Name[de]=$APPLICATION_NAME\n".
									"Exec=\"%s/$PROGRAM_TO_START\"\n".
									"Path=%s\n".
									"StartupNotify=true\n".
									"Terminal=false\n".
									"Type=Application\n".
									"Icon=$APP_ICON_FILE_NAME\n".
									"Categories=Graphics;\n".
									"MimeType=$MIME_TYPE\n";
my $MIME_TYPE_FILE_FORMAT		= "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n".
									"<mime-info xmlns='http://www.freedesktop.org/standards/shared-mime-info'>\n".
									"<mime-type type=\"%s\">\n".
									"<comment>%s</comment>\n".
									"<glob pattern=\"*.mcf\"/>\n".
									"</mime-type>\n".
									"</mime-info>";
my $SERVICES_XML_FORMAT			= "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>".
									"<services>".
									"<service name=\"a\">t856EvnDTL56xD5fHQnWrzqVk6Xj3we4xGYHfShPmkqXtCzbI21eqJ57eIHVViAg</service>".
									"<service name=\"b\">SNCxjcl5y86nasXrdmtwTWWbBmFs3j21rZOVvoZT9HleOfGJR7FGgZiXsS623ctV</service>".
									"<service name=\"c\">7iIwPfB9c6TIRuf9SPd7I1j25Pex9atTL9TDepMD6nkAyDliZhvIlJOC2tm9pcyQ</service>".
									"<service name=\"d\">%s</service>".
									"<service name=\"e\">EQBuKJf7pzVIbNXzz19PlwkVpERC5KfsWJbG4cazpn3PFC5Rtz4O3V87KcWfMgxK</service>".
									"<service name=\"f\">8ksOkroMJFn1Es3zVJyzxJggNaXiMuLKBfPLBtCyek1bZBcTy29gaU7nm75ZYIxz</service>".
									"<service name=\"g\">xHuXMWCLmtrwNIBvqVB9BAyPjNpEa9gNuybXU51bKsryDqc2UJxSQXM8yIhbIarq</service>".
									"<service name=\"h\">sKTtqevc5EdBSwi3bZkngwl4NSolB8vFc7kPWeAEB4Y1ySgUIgcjJGxKlOll8c8e</service>".
									"</services>\n";

my $DOWNLOAD_START_URL			= "http://dls.photoprintit.com/api/feedback/$KEYACCID/hps/<update>downloadstart.$AFFILIATE_ID/linux/$HPS_VER";
my $DOWNLOAD_COMPLETE_URL		= "http://dls.photoprintit.com/api/feedback/$KEYACCID/hps/<update>downloadcomplete.$AFFILIATE_ID/linux/$HPS_VER";
my $INSTALLATION_COMPLETE_URL	= "http://dls.photoprintit.com/api/feedback/$KEYACCID/hps/<update>installationcomplete.$AFFILIATE_ID/linux/$HPS_VER";


################################################################################
#
# Variablen
#
################################################################################
my $indexContent;			# Enthält den Inhalt der Index-Datei
my @filesToDownload;		# Enthält die Dateinamen die heruntergeladen werden müssen
my %packagesToUnzip;		# Enthält die Dateinamen der heruntergeladenen Dateien
my @packagesToRemove;		# Enthält die Dateinamen der Pakete, die am Ende des Scripts wieder gelöscht werden müssen.
my @filesToRemove;			# Enthält die Dateinamen der Dateien die am Ende des Scriptes gelöscht werden müssen.
my @filesCreated;           # Enthält die Dateien, die vom Installer zusätzlich angelegt wurden.
my @uninstallCommands;		# Enthält die Befehle, die der Uninstaller ausführen muss um den HPS wieder komplett zu deinstallieren.
my $fileName;				# Enthält den Namen der aktuell zu bearbeitenden Datei
my $update;
my $upgrade;
my $installDir = "";
my $sourceDir = "";
my $changeInstallDir = 1;
my $verbose;
my $keepPackages = 0;
my $workingDir = cwd();		# Aktuelles Verzeichnis wird das Arbeitsverzeichnis.


################################################################################
#
# Zeige einen kleinen Hilfetext an
#
################################################################################
sub showHelp {
	printf ($TRANSLATABLE[4], $APPLICATION_NAME);
	printf ($TRANSLATABLE[20], $APPLICATION_NAME);

	exit(0);
}


################################################################################
#
# Parse Kommandozeilen Parameter
#
################################################################################
sub getOptions {
	$update = 0;
	$upgrade = 0;
	$verbose = 0;
	$installDir = "";
	my $showHelp = 0;

	GetOptions("installdir=s" => \$installDir,
				"update" => \$update,
				"upgrade" => \$upgrade,
				"verbose" => \$verbose,
				"help" => \$showHelp,
				"keepPackages" => \$keepPackages,
				"workingdir=s" => \$workingDir) || abort($TRANSLATABLE_ERRORS[0]);

	if ($showHelp == 1) {
		showHelp();
	}

	if ($upgrade == 1) {
		$update = 1;
	}

	if ($update == 1
	   && $installDir eq "") {
		abort($TRANSLATABLE_ERRORS[1]);
	}

	if ($installDir ne "") {
		$changeInstallDir = 0;
	}
}


################################################################################
#
# Deinstalliert den ganzen HPS wieder.
#
################################################################################
sub uninstall {
	my $installDir = getcwd();
	my $ownerUID = (stat($installDir))[4];

	if ($ownerUID ne $>) {
		abort(sprintf($TRANSLATABLE_ERRORS[18], $APPLICATION_NAME, getpwuid($ownerUID)));
	}

	if (yesNoAnswer(sprintf($TRANSLATABLE[21], $APPLICATION_NAME, $installDir), 0)) {
		if (opendir(LOG_FILE_DIR, "$installDir/$LOG_FILE_DIR")) {
			my @allFiles = readdir(LOG_FILE_DIR);
			@allFiles=grep(!/^\./, @allFiles);

			close(LOG_FILE_DIR);

			foreach (@allFiles) {
				removePackage("$installDir/$LOG_FILE_DIR/$_");
			}
		}

		# Alle leeren Verzeichnisse wegräumen.
		system("find \"$installDir\" -type d -empty -delete");
	}

	exit 0;
}


################################################################################
#
# Liest eine Ja/Nein Entscheidung des Benutzers ein
#
################################################################################
sub yesNoAnswer {
	my $text = $_[0];
	my $default = $_[1];
	my $choice;

	if ($default == 1) {
		$choice = sprintf("[\033[1m%1\$s\033[0m/%2\$s]", uc($TRANSLATABLE[0]), $TRANSLATABLE[2]);
	} else {
		$choice = sprintf("[%1\$s/\033[1m%2\$s\033[0m]", $TRANSLATABLE[0], uc($TRANSLATABLE[2]));
	}

	printf("$text $choice ");

	my $answer = <STDIN>;
	chomp($answer);
	$answer = lc($answer);

	if ($answer ~~ @ANSWER_YES_LIST) {
		return 1;
	} elsif ($answer ~~ @ANSWER_NO_LIST) {
		return 0;
	}

	return $default;
}


################################################################################
#
# Prüft das Arbeitsverzeichnis
#
################################################################################
sub checkWorkingDir {
	my $testFileName = "test";

	if (!opendir(DIR, $workingDir)) {
		abort($TRANSLATABLE_ERRORS[2], $workingDir);
	} else {
		closedir(DIR);
	}
	my $testFilePath = "$workingDir/$testFileName";

	if (!open(TEST_FILE, ">", $testFilePath)) {
		$workingDir = "/tmp";
		$testFilePath = "$workingDir/$testFileName";

		if (!open(TEST_FILE, ">", $testFilePath)) {
			abort($TRANSLATABLE_ERRORS[3]);

		} else {
			close(TEST_FILE);
			unlink($testFilePath);
		}
	} else {
		close(TEST_FILE);
		unlink($testFilePath);
	}
}


################################################################################
#
# Prüfe ob benötigte Programme da sind
#
################################################################################
sub checkProgramms {
	foreach (@REQUIRED_PROGRAMMS) {
		my $status = system("which $_ > /dev/null 2>&1");

		if ($status != 0) {
			abort($TRANSLATABLE_ERRORS[4], $_);
		}
	}
}


################################################################################
#
# Zeigt die EULA an
#
################################################################################
sub showEula {
	if ($FILE_EULA ne "" && $update == 0) {
		if (!open(EULA, "<", $FILE_EULA)) {
			abort($TRANSLATABLE_ERRORS[5], $FILE_EULA);
		}
		close EULA;
		printf($TRANSLATABLE[5]);
		my $answer = <STDIN>;

	#	system("less $FILE_EULA");

	#	if (yesNoAnswer($TRANSLATABLE[6], 0) == 0) {
	#		abort($TRANSLATABLE_ERRORS[6], sprintf($TRANSLATABLE[7], $APPLICATION_NAME));
	#	}
	}
}


################################################################################
#
# Installationsverzeichniss erfragen
#
################################################################################
sub getInstallDir {
	if ($update == 0 && $changeInstallDir == 1) {
		while (1) {
			if ($> == 0) {	# Root User
				$installDir = "/opt/$INSTALL_DIR_DEF";
			} else {		# Normaler Benutzer
				$installDir = "$ENV{'HOME'}/$INSTALL_DIR_DEF";
			}

			printf($TRANSLATABLE[8], $APPLICATION_NAME, $installDir);
			my $answer = <STDIN>;
			chomp($answer);

			if ($answer ne "") {
				$installDir = $answer;
			}

			# vorne und hinten Leerzeichen abschneiden
			$installDir =~ s/^\s+//;
			$installDir =~ s/\s+$//;

			# Jetzt ersetzen wir noch die Tilde durch das Home-Verzeichnis
			$installDir =~ s/^~/$ENV{"HOME"}/;

			# einen relativen Pfad um den aktuellen Pfad erweitern
			if ($installDir =~ m/^[^\/]/) {
				$installDir = "$ENV{'PWD'}/$installDir";
			}

			my $dirCreated = 0;
			if (! -e $installDir) {
				if (yesNoAnswer($TRANSLATABLE[19], 1)) {
					# Installationsverzeichniss anlegen
					make_path("$installDir/$LOG_FILE_DIR", {error => \my $error });

					if (@$error) {
						printf(red($TRANSLATABLE_ERRORS[12]), $installDir);
						next;
					}

					$dirCreated = 1;
				} else {
					next;
				}
			}

			my $symlinkTestFile = "$installDir/symlinks_possible";
			my $symlinks_possible = symlink($symlinkTestFile, $symlinkTestFile);

			if ($symlinks_possible) {
				unlink $symlinkTestFile;
				last;
			} else {
				if ($dirCreated == 1) {
					rmtree($installDir);
				}
				abort($TRANSLATABLE_ERRORS[7], $APPLICATION_NAME);
			}
		}
	}
}


################################################################################
#
# Holt die Index-Datei
#
################################################################################
sub getIndexFile {
	my $downloaded = 0;
	my $answer = 1;

	$fileName = basename($INDEX_FILE_PATH_ON_SERVER);

	if (! -e $fileName
		|| -s $fileName == 0) {
		# Hole Indexdatei aus dem Netz.

		$fileName = "$workingDir/$fileName";

		if ($verbose == 0) {
			$answer = system("wget -T 60 -t 1 -q $DOWNLOAD_SERVER$INDEX_FILE_PATH_ON_SERVER -O $fileName");
		} else {
			$answer = system("wget -T 60 -t 1 $DOWNLOAD_SERVER$INDEX_FILE_PATH_ON_SERVER -O $fileName");
		}

		if ($answer != 0
			|| -s $fileName == 0) {
			unlink($fileName);
			abort($TRANSLATABLE_ERRORS[8], $DOWNLOAD_SERVER.$INDEX_FILE_PATH_ON_SERVER);
		}

		$downloaded = 1;
	}

	if (!open(INDEX, "<", $fileName)) {
		abort($TRANSLATABLE_ERRORS[9], $fileName);

	} else {
		while(<INDEX>) {
			$indexContent.=$_;
		}

		close(INDEX);

		if ($downloaded == 1 && $keepPackages == 0) {
			push(@packagesToRemove, $fileName);
		}
	}
}


################################################################################
#
# Checkt Index-Datei und sucht die herunter zu ladenden Dateien zusammen
#
################################################################################
sub checkIndexFile {
	my $totalSize = 0;
	my $packageString = "";
	my $machineType = `uname -m`;

	chomp($machineType);

	if ($machineType eq "i686") {
		$machineType = "l";
	} elsif ($machineType eq "x86_64") {
		$machineType = "l64";
	} else {
		abort($TRANSLATABLE_ERRORS[10], $machineType);
	}

	if (length($indexContent) == 0) {
		abort($TRANSLATABLE_ERRORS[17]);
	}

	foreach (split(/[\r\n]+/, $indexContent)) {
		chomp;
		if (/^(.*);(.*);(.*);(.*)$/) {
			my $filePath = $1;
			my $required = $2;
			my $what = $3;
			my $system = $4;

			if ($system eq $machineType || $system eq "a") {
				$fileName = basename($filePath);

				if (! -e "$installDir/$LOG_FILE_DIR/$fileName.log") {
					# Die Datei ist noch nicht installiert.
					if ( -e $fileName ) {
						# Die Datei liegt lokal vor, also brauchen wir sie nicht herunter zu laden
						$packagesToUnzip{$fileName} = $what;
#						push(@packagesToUnzip, $fileName);

					} else {
						my $file2get;
						if ($filePath =~ m/^https:/) {
							$file2get = $filePath;
						} else {
							$file2get = "$DOWNLOAD_SERVER/$filePath";
						}
						# Die Datei muss aus dem Netz gezogen werden. Schreiben wir mal raus wie viel da herunter geladen werden muss.
						my $spider = `export LANG=C;export LC_MESSAGES=C;wget --spider $file2get 2>&1`;
						my ($size, $dummy, $mb, $mime)	= $spider=~/Length:\s+([\d\.,]+)\s+(\(([\d\.,]+[MK]?)\))?\s*(\[.*\])/;
						my $string = sprintf($TRANSLATABLE[14], $what, $size/(1024*1024));
						$packageString .= $string;
						push(@filesToDownload, $_);
						$size =~ s/[\.,]//g;
						$totalSize += $size;
					}
				}
			}
		}
	}

	if (scalar(@filesToDownload) != 0) {
		printf($TRANSLATABLE[16]);
		printf($packageString);
		if ($update == 0
			&& yesNoAnswer(sprintf($TRANSLATABLE[9], $totalSize/(1024*1024)), 1) == 0) {
			exit 1;
		}
	}
}


################################################################################
#
# Löscht ein altes Paket wieder von der Platte, welches nicht mehr benutzt wird.
#
################################################################################
sub roleback {
	my ($fileName) = @_;
	$fileName =~ /^$CLIENTID-(.*)-(\d+.\d+.\d+)_.*$/;
	my $packageName = $1;

	if (opendir(LOG_FILE_DIR, $installDir."/".$LOG_FILE_DIR)) {
		my @allFiles=readdir(LOG_FILE_DIR);
		@allFiles=grep(!/^\./, @allFiles);

		close(LOG_FILE_DIR);

		foreach (@allFiles) {
			$_ =~ /^$CLIENTID-(.*)-(\d+.\d+.\d+)_.*$/;

			if ($1 eq $packageName) {
				removePackage("$installDir/$LOG_FILE_DIR/$_");
			}
		}
	}
}


################################################################################
#
# Lösche Dateien aus einem Logfile und das Logfile selbst
#
################################################################################
sub removePackage {
	my $logFile = $_[0];
	my @files;
	my @dirs;

	if (open(LOG_FILE, "<", $logFile)) {
		while(<LOG_FILE>) {
			if (/^\s*inflating:\s+(.*)/) {
				my $file = $1;
				$file =~ s/^\s+|\s+$//;
				push(@files, $file);
			}
			if (/^\s*creating:\s+(.*)\s*$/) {
				push(@dirs, $1);
			}
			if (/^\s*created:\s+(.*)/) {
				my $file = $1;
				$file =~ s/^\s+|\s+$//;
				push(@files, $file);
			}
			if (/^\s*command:\s+(.*)/) {
				system($1);
			}
		}
		close LOG_FILE;
	}

	# Füge das Logfile zur Liste der zu löschenden Dateien hinzu.
	push(@files, $logFile);

	unlink(@files);

	foreach (reverse(@dirs)) {
		rmdir($_);
	}
}


################################################################################
#
# Lädt alle Dateien aus der Index-Datei herunter
#
################################################################################
sub downloadFiles {
	if (scalar(@filesToDownload) != 0) {

		triggerCountPixel($DOWNLOAD_START_URL);

		# Herunterladen der Dateien
		foreach (@filesToDownload) {
			chomp;
			$_ =~ /^(.*);.*;(.*);.*$/;
			my $filePath = $1;
			my $what = $2;
			my $error = 0;
			my $retry = 1;

			$fileName = $workingDir . "/" . basename($filePath);

			printf($TRANSLATABLE[10], $what);

			while($retry == 1) {
				my $result = 1;
				my $file2get;

				if ( $filePath =~ m/^https:/) {
				   $file2get = $filePath;
				} else {
				   $file2get = $DOWNLOAD_SERVER."/".$filePath;
				}

				if ($verbose == 0) {
					$result = system("wget -q $file2get -O $fileName");
				} else {
					$result = system("wget $file2get -O $fileName");
				}

				if ($result == 0) {
					# Extrahiere MD5 Summe
					$fileName =~ /^.*_(.*).zip$/;
					my $md5sum = $1;

					# Berechne MD5 Summe der Datei
					$result = `md5sum $fileName`;
					$result =~ /^(\w*)\s+.*$/;
					my $fileMd5sum = $1;

					if ($md5sum ne $fileMd5sum) {
						printf(red($TRANSLATABLE_ERRORS[15]), $fileName);
						$error = 1;
					} else {
						$packagesToUnzip{$fileName} = $what;
#						push(@packagesToUnzip, $fileName);
						push(@packagesToRemove, $fileName);
						$retry = 0;
					}
				} else {
					printf(red($TRANSLATABLE_ERRORS[16]), $file2get, $fileName);
					$error = 1;
				}

				if ($update == 0 && $error == 1) {
					$retry = yesNoAnswer($TRANSLATABLE[13], 0);

				} elsif ($update == 1 && $error == 1) {
					# Wir haben keine Konsole und können keine Eingabe entgegen nehmen.
					# Deshalb brechen wir ab.
					$retry = 0;
				}
			}

			printf($TRANSLATABLE[23]);

			if ($error == 1) {
				unlink $fileName;
				abort($TRANSLATABLE_ERRORS[11], $fileName);
			}
		}

		triggerCountPixel($DOWNLOAD_COMPLETE_URL);
	}
}


################################################################################
#
# Prüfen und entpacken der Dateien
#
################################################################################
sub unpackFiles {
	if (scalar(keys(%packagesToUnzip)) != 0) {
		printf($TRANSLATABLE[11]);

		make_path("$installDir/$LOG_FILE_DIR", {error => \my $error });

		if (@$error) {
			abort(red($TRANSLATABLE_ERRORS[12]), $installDir);
		}

		# Alte symbolische Links wegwerfen, System Integration, Icons, Mimetype, ... löschen
		removePackage("$installDir/$LOG_FILE_DIR/$INSTALL_LOG_FILE_NAME");

		# Entpacken der Dateien
		foreach (keys(%packagesToUnzip)) {
			chomp;
			$fileName = $_;
			my $fileBaseName = basename($fileName);

			printf($TRANSLATABLE[22], $packagesToUnzip{$fileName});

			# Hier können wir eine evtl. installierte Vorgängerversion löschen.
			# Die md5 Summen aller Downloads stimmen, also sollten sich alle Pakete entpaken lassen
			roleback($fileBaseName);

			my $result = 0;
			my @unzipReturn;
			@unzipReturn = `unzip -o -d '$installDir' $fileName 2>&1`;

			foreach (@unzipReturn) {
				if (/^\s*error:/) {
					$result = 1;
				} elsif (/cannot find/) {
					$result = 1;
				}
			}

			if (open(OUT, ">", "$installDir/$LOG_FILE_DIR/$fileBaseName.log")) {
				print OUT  @unzipReturn;
				close(OUT);
			}

			if ($result != 0) {
				abort($TRANSLATABLE_ERRORS[13], $fileName);
			}

			printf($TRANSLATABLE[23]);
		}
	}
}


################################################################################
#
# Icons für Mimetyp und Application erzeugen
#
################################################################################
sub createIcons {
	my $mimeTypeFileName = $MIME_TYPE;
	$mimeTypeFileName =~ tr:/:-:;

	my @sizes = (16, 22, 24, 32, 48, 64, 128);

	system("\"$installDir/IconExtractor\" \"$installDir$DESKTOP_ICON_PATH\" @sizes > /dev/null 2>&1");

	foreach (@sizes) {
		my $iconFileName = "cewe_$_.png";
		system("xdg-icon-resource install --noupdate --theme hicolor --context apps --size $_ $iconFileName $APP_ICON_FILE_NAME");
		push(@uninstallCommands, "xdg-icon-resource uninstall --noupdate --theme hicolor --context apps --size $_ $APP_ICON_FILE_NAME");

		system("xdg-icon-resource install --noupdate --theme hicolor --context mimetypes --size $_ $iconFileName $mimeTypeFileName");
		push(@uninstallCommands, "xdg-icon-resource uninstall --noupdate --theme hicolor --context mimetypes --size $_ $mimeTypeFileName");

		push(@filesToRemove, $iconFileName);
	}

	system("xdg-icon-resource forceupdate");
	push(@uninstallCommands, "xdg-icon-resource forceupdate");
}


################################################################################
#
# Informationen zum Mimetyp erzeugen.
#
################################################################################
sub createMimeType() {
	if ($IS_FOTOSCHAU_INSTALLER != 1) {
		my $mimeTypeFileName = "$MIME_TYPE.xml";
		$mimeTypeFileName =~ tr:/:-:;

		if (!open(MIME_TYPE_FILE, ">", "$mimeTypeFileName")) {
			abort($TRANSLATABLE_ERRORS[9], $mimeTypeFileName);

		} else {
			printf(MIME_TYPE_FILE $MIME_TYPE_FILE_FORMAT, $MIME_TYPE, $APPLICATION_NAME);
			close(MIME_TYPE_FILE);

			system("xdg-mime install \"$mimeTypeFileName\"");
			push(@uninstallCommands, "xdg-mime uninstall \"$mimeTypeFileName\"");

			my $mimeDir = "$ENV{'HOME'}/.local/share/mime";
			if ($> == 0) {
				$mimeDir = "/usr/share/mime";
			}

			system("update-mime-database \"$mimeDir\"");
			push(@uninstallCommands, "update-mime-database $mimeDir");
		}

		push(@filesCreated, "$installDir/$mimeTypeFileName");
	}
}


################################################################################
#
# Einträge im Startmenü erzeugen
#
################################################################################
sub createDesktopShortcuts {
	my $desktopFileName = $DESKTOP_FILE_NAME;
	$desktopFileName =~ tr:/:-:;

	if (!open(DESKTOP_FILE, ">", $desktopFileName)) {
		abort($TRANSLATABLE_ERRORS[9], $desktopFileName);

	} else {
		printf(DESKTOP_FILE $DESKTOP_FILE_FORMAT, $installDir, $installDir);
		close(DESKTOP_FILE);

		system("xdg-desktop-menu install --novendor \"$desktopFileName\"");
		push(@uninstallCommands, "xdg-desktop-menu uninstall \"$desktopFileName\"");

		system("xdg-desktop-icon install --novendor \"$desktopFileName\"");
		push(@uninstallCommands, "xdg-desktop-icon uninstall \"$desktopFileName\"");
	}

	push(@filesCreated, $desktopFileName);
}


################################################################################
#
# Pfade zu den gerade installierten Executables in die Registry eintragen.
#
################################################################################
sub registerExecutables {
	if ($IS_FOTOSCHAU_INSTALLER == 1) {
		system("\"$installDir/regedit\" \"$installDir/$PROGRAM_NAME_FOTOSHOW\" \"$installDir/$PROGRAM_NAME_FOTOIMPORTER\" > /dev/null 2>&1");
	} else {
		system("\"$installDir/regedit\" \"$installDir/$PROGRAM_NAME_FOTOSHOW\" \"$installDir/$PROGRAM_NAME_FOTOIMPORTER\" \"$installDir/$PROGRAM_NAME_HPS\" > /dev/null 2>&1");
	}
}


################################################################################
#
# Abschließende Arbeiten, symbolische Links anlegen, Programme ausführbar machen, ...
#
################################################################################
sub finalizeInstallation {
	if (opendir(INSTALL_DIR, $installDir)) {
		chdir($installDir);
		my @allFiles=sort{ $a cmp $b } readdir(INSTALL_DIR);

		# Werfe alle Einträge mit einem Punkt am Anfang weg
		@allFiles=grep(!/^\./, @allFiles);
		my @libFiles=grep(/.+\.so\.\w*/, @allFiles);

		# Erzeuge Symlinks für Libs
		foreach (@libFiles) {
			my $fileName = $_;

			if (-l $fileName) {
				# symbolische Links auf symbolische Links wollen wir nicht.
				next;
			}

			$fileName =~ /(.+\.so)\.(.*)/;
			my $baseFileName = $1;
			my $version = $2;

			my @v = split(/\./, $version);

			unlink($baseFileName);
			symlink($fileName, $baseFileName);
			push(@filesCreated, $baseFileName);

			foreach (@v) {
				$baseFileName .= ".$_";
				if ($baseFileName ne $fileName) {
					unlink($baseFileName);
					symlink($fileName, $baseFileName);
					push(@filesCreated, $baseFileName);
				}
			}
		}

		# Kopiere Uninstall Script und EULA ins Installationsverzeichnis.
		my %filesToCopy;
		$filesToCopy{$PROGRAM_NAME_INSTALLER} = $PROGRAM_NAME_UNINSTALLER;
		$filesToCopy{$FILE_EULA} = $FILE_EULA;
		my @sourceFiles = keys(%filesToCopy);

		foreach (@sourceFiles) {
			my $sourceFile = "$workingDir/$_";
			my $targetFile = "$installDir/$filesToCopy{$_}";

			copy("$sourceFile", $targetFile);
			push(@filesCreated, $targetFile);
		}

		# Ändere Dateirechte
		my @binaries;
		push(@binaries, $PROGRAM_NAME_HPS);
		push(@binaries, $PROGRAM_NAME_FOTOSHOW);
		push(@binaries, $PROGRAM_NAME_FOTOIMPORTER);
		push(@binaries, $PROGRAM_NAME_UNINSTALLER);
		push(@binaries, $PROGRAM_NAME_FACEDETECTION);
		push(@binaries, $PROGRAM_NAME_GPUPROBE);
		push(@binaries, $PROGRAM_NAME_ICONEXTRACTOR);
		push(@binaries, $PROGRAM_NAME_REGEDIT);
		push(@binaries, $PROGRAM_NAME_QTWEBENGINEPROCESS);
		push(@binaries, $PROGRAM_NAME_UPDATER);

		chmod(0755, @binaries);

		closedir(INSTALL_DIR);
	}

	if ($AFFILIATE_ID ne '') {
		my $servicesXMLFilePath = "$installDir/$SERVICES_XML_PATH";

		if (open(SERVICESXML, ">", $servicesXMLFilePath)) {
			printf SERVICESXML $SERVICES_XML_FORMAT, $AFFILIATE_ID;
			close(SERVICESXML);

			push(@filesCreated, $servicesXMLFilePath);
		}
	}
}


################################################################################
#
# Zählpixel URL aufrufen und die dabei heruntergeladene Datei löschen.
#
################################################################################
sub triggerCountPixel {
	my $pixelFile = "pixel";

	if ($upgrade == 1) {
		$_[0] =~ s/<update>/genericupgrade/;
	} elsif ($update == 1) {
		$_[0] =~ s/<update>/update/;
	} else {
		$_[0] =~ s/<update>//;
	}

	if ($workingDir ne "") {
		$pixelFile = "$workingDir/$pixelFile";
	}

	system("wget -q $_[0] -O $pixelFile");
	unlink $pixelFile
}


################################################################################
#
# Meldung in rot.
#
################################################################################
sub red {
	return sprintf("\033[31m%s\033[0m", $_[0]);
}


################################################################################
#
# Fehlermeldung ausgeben und abbrechen
#
################################################################################
sub abort {
	my $message = shift(@_);
	printf(red($message), @_);
	exit 1;
}


################################################################################
#
# Übersetzungen laden
#
################################################################################
sub loadTranslations {
	if (open(TRANSLATIONS, "<", "translations.pl")) {
		my $translationCode;

		while(<TRANSLATIONS>) {
			$translationCode .= $_;
		}

		close(TRANSLATIONS);

		eval($translationCode);

		@ANSWER_YES_LIST = ($TRANSLATABLE[0], $TRANSLATABLE[1]);
		@ANSWER_NO_LIST  = ($TRANSLATABLE[2], $TRANSLATABLE[3]);
	}
}


################################################################################
#
# Aufräumen, alle angelegten Dateien entfernen.
#
################################################################################
sub cleanup {
	if ($keepPackages == 0) {
		unlink(@packagesToRemove);
	} else {
		printf($TRANSLATABLE[17]);
	}

	unlink(@filesToRemove);
}


################################################################################
#
# Datei schreiben, was ausgeführt und gelöscht werden muss um den HPS wieder komplett zu deinstallieren.
#
################################################################################
sub writeInstallLog {
	if (open(INSTALL_LOG_FILE, ">", "$installDir/$LOG_FILE_DIR/$INSTALL_LOG_FILE_NAME")) {
		foreach (@uninstallCommands) {
			printf(INSTALL_LOG_FILE "command: $_\n");
		}

		foreach (@filesCreated) {
			printf(INSTALL_LOG_FILE "created: $_\n");
		}

		close(INSTALL_LOG_FILE);
	}
}


################################################################################
#
# MAIN
#
################################################################################
# Erzwinge eine Leerung der Puffer nach jeder print()-Operation
$| = 1;

system("clear");

if (basename($0) eq $PROGRAM_NAME_UNINSTALLER) {
	uninstall();

} else {
	loadTranslations();
	getOptions();
	printf($TRANSLATABLE[4], $APPLICATION_NAME);
	checkWorkingDir();
	checkProgramms();
	showEula();
	getInstallDir();
	getIndexFile();
	checkIndexFile();
	downloadFiles();
	unpackFiles();
	finalizeInstallation();
	createIcons();
	createMimeType();
	createDesktopShortcuts();
	registerExecutables();
	writeInstallLog();
	cleanup();
	triggerCountPixel($INSTALLATION_COMPLETE_URL);

	my $executablePath = $installDir . "/" . $APPLICATION_NAME;
	$executablePath =~ s/\/+/\//g;
	printf($TRANSLATABLE[12], $APPLICATION_NAME, $executablePath);
}
