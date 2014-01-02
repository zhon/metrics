export BUILD_DIR='/home/jefgro/Vulnerability_Management/core/trunk'
export SEC_BUILD_DIR='/home/jefgro/Vulnerability_Management/security/trunk'
export COMMON_BUILD_DIR='/home/jefgro/Vulnerability_Management/common/trunk'
export RESPONSE_PKG_DIR='/home/jefgro/Security_Response_Package'
export COM_CLASS_FILES='/home/jefgro/Vulnerability_Management/core/trunk/classes/com'
export QA_CLASS_FILES='/home/jefgro/Vulnerability_Management/core/trunk/classes/qa'
export SRC_DIR='/home/jefgro/Vulnerability_Management/core/trunk/src'
export TOOLS_DIR='/home/jefgro/Vulnerability_Management/core/trunk/tools/ruby'
export DATA_DIR='/var/www/html/rdata'
export GNUPLOT_DIR='/var/www/html/rdata/gnuplot'
export METRICS_LOG_FILE='/home/jefgro/Vulnerability_Management/core/trunk/metrics.log'
export BUILD_FILE='build.txt'
export BUILD_ERR_FILE='build_err.txt'
export BUILD_PAGE='/var/www/html/rdata/build.html'
export IMPORTS_PAGE='/var/www/html/rdata/imports.html'
export IMPORTS_FILE='imports.txt'
export TODO_PAGE='/var/www/html/rdata/todo.html'
export TODO_FILE='todo.txt'
export SESA_PAGE='/var/www/html/rdata/sesa.html'
export SESA_FILE='sesa.txt'
export CHANGES_PAGE='/var/www/html/rdata/changes.html'
export CHANGES_FILE='changes.txt'
export DETAILS_FILE='details.txt'
export DETAILS_PAGE='/var/www/html/rdata/details.html'
export DEPEND_FILE='depend.txt'
export DEPEND_PAGE='/var/www/html/depend.html'
export RUBY='env ruby'
export P4USER='jeff_grover'
export P4PORT='172.17.1.7:1666'
export JAVA_HOME='/usr/java/jdk1.3.1_04'
export JDEPEND_COMMAND='java -classpath tools/java/jdepend.jar jdepend.textui.JDepend -file depend.txt classes ../../common/trunk/build ../../security/trunk/build'
export IMPORT_CLEANER='/home/jefgro/Vulnerability_Management/core/trunk/tools/java/importcleaner.jar'

# Update from Perforce and compile 
echo 'Metrics gathering started:' >> $METRICS_LOG_FILE
#date >> $METRICS_LOG_FILE
cd $RESPONSE_PKG_DIR
p4 sync ...
cd $BUILD_DIR
p4 sync ../../...
bin/ant -verbose clean-global > $BUILD_FILE 2> $BUILD_ERR_FILE
bin/ant -verbose build-common >> $BUILD_FILE 2>> $BUILD_ERR_FILE
bin/ant -verbose build-security >> $BUILD_FILE 2>> $BUILD_ERR_FILE
bin/ant -verbose compile-all >> $BUILD_FILE 2>> $BUILD_ERR_FILE
bin/ant -verbose compile-all >> $BUILD_FILE 2>> $BUILD_ERR_FILE
echo '<html><body><pre>' > $BUILD_PAGE
$RUBY -pe 'gsub("<", "&LT ");gsub(">", " &GT")' < $BUILD_FILE >> $BUILD_PAGE
echo  >> $BUILD_PAGE
echo 'ERRORS REPORTED BELOW: ------------------------------------------------------'  >> $BUILD_PAGE
echo  >> $BUILD_PAGE
$RUBY -pe 'gsub("<", "&LT ");gsub(">", " &GT")' < $BUILD_ERR_FILE >> $BUILD_PAGE
echo '</pre></body></html>' >> $BUILD_PAGE

# Gather all metrics
cp $TOOLS_DIR/*.rb .
$RUBY metrics.rb -a . -g $DATA_DIR -v 50 > $DETAILS_FILE
echo '<html><body><pre>' > $DETAILS_PAGE
$RUBY -pe 'gsub("<", "&LT ");gsub(">", " &GT")' < $DETAILS_FILE >> $DETAILS_PAGE
echo '</pre></body></html>' >> $DETAILS_PAGE

# Gather unused import metrics (activity infers refactoring)
cd $BUILD_DIR
rm *.dat
cp -r $COM_CLASS_FILES $SRC_DIR
cp -r $QA_CLASS_FILES $SRC_DIR
cp $IMPORT_CLEANER .
$RUBY imports.rb src > $IMPORTS_FILE
echo '<html><body><pre>' > $IMPORTS_PAGE
$RUBY -pe 'gsub("<", "&LT ");gsub(">", " &GT")' < $IMPORTS_FILE >> $IMPORTS_PAGE
echo '</pre></body></html>' >> $IMPORTS_PAGE
cat imports.dat >> $DATA_DIR/imports.dat
find src -name *.class -print | xargs rm

# Gather TO DO comment metrics
cd $BUILD_DIR
grep -ri "\/.*todo" src > todo.txt
grep -ri "\/.*todo" src | wc -l > todo.num
echo '<html><body><pre>' > $TODO_PAGE
$RUBY -pe 'gsub("<", "&LT ");gsub(">", " &GT")' < $TODO_FILE >> $TODO_PAGE
echo '</pre></body></html>' >> $TODO_PAGE
$RUBY datestamp.rb >> $DATA_DIR/todo.dat
cat todo.num >> $DATA_DIR/todo.dat

# Gather SESA dependencies metrics
cd $BUILD_DIR
$RUBY sesadep.rb src > $SESA_FILE
echo '<html><body><pre>' > $SESA_PAGE
$RUBY -pe 'gsub("<", "&LT ");gsub(">", " &GT")' < $SESA_FILE >> $SESA_PAGE
echo '</pre></body></html>' >> $SESA_PAGE
cat sesa.dat >> $DATA_DIR/sesa.dat

# Gather JDepend dependencies metrics
cd $BUILD_DIR
$JDEPEND_COMMAND
echo '<html><body><pre>' > $DEPEND_PAGE
$RUBY -pe 'gsub("<", "&LT ");gsub(">", " &GT")' < $DEPEND_FILE >> $DEPEND_PAGE
echo '</pre></body></html>' >> $DEPEND_PAGE
# TODO:  count dependency cycles, other metrics

# Gather most often changed files metrics 
cd $BUILD_DIR
$RUBY tools/ruby/changed.rb > $CHANGES_FILE
echo '<html><body><pre>' > $CHANGES_PAGE
$RUBY -pe 'gsub("<", "&LT ");gsub(">", " &GT")' < $CHANGES_FILE >> $CHANGES_PAGE
echo '</pre></body></html>' >> $CHANGES_PAGE

# Gather unit test metrics
$RUBY tests.rb 
cat tests.dat >> $DATA_DIR/tests.dat
cat run.dat >> $DATA_DIR/run.dat
cat fail.dat >> $DATA_DIR/fail.dat
cat error.dat >> $DATA_DIR/error.dat

# Generate metrics graphs
cd $DATA_DIR
gnuplot $GNUPLOT_DIR/lines.gp
gnuplot $GNUPLOT_DIR/longest.gp
gnuplot $GNUPLOT_DIR/average.gp
gnuplot $GNUPLOT_DIR/indup.gp
gnuplot $GNUPLOT_DIR/exdup.gp
#gnuplot $GNUPLOT_DIR/warnings.gp
gnuplot $GNUPLOT_DIR/dead.gp
gnuplot $GNUPLOT_DIR/unused.gp
#gnuplot $GNUPLOT_DIR/avg_depend.gp
#gnuplot $GNUPLOT_DIR/max_depend.gp
#gnuplot $GNUPLOT_DIR/cycles.gp
gnuplot $GNUPLOT_DIR/switch.gp
gnuplot $GNUPLOT_DIR/case.gp
gnuplot $GNUPLOT_DIR/if.gp
gnuplot $GNUPLOT_DIR/tests.gp
gnuplot $GNUPLOT_DIR/run.gp
gnuplot $GNUPLOT_DIR/fail.gp
gnuplot $GNUPLOT_DIR/error.gp
gnuplot $GNUPLOT_DIR/imports.gp
gnuplot $GNUPLOT_DIR/todo.gp
gnuplot $GNUPLOT_DIR/sesa.gp

cd $BUILD_DIR
echo 'Completed:' >> $METRICS_LOG_FILE
date >> $METRICS_LOG_FILE
