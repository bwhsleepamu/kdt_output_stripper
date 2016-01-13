var gulp = require('gulp'),
    sass = require('gulp-sass');
    
var config = {
  sassPath: "./sass",
  bowerDir: "./bower_components",
  cssPath: "./css",
  publicDir: "./www"
}    
    
gulp.task('styles', function() {
  return gulp.src(config.sassPath + "/app.scss") 
    .pipe(sass({
      includePaths: [config.bowerDir+'/bootstrap-sass/assets/stylesheets']
    }))
    .pipe(gulp.dest(config.publicDir + '/css'));
});

gulp.task('icons', function() {
  return gulp.src(config.bowerDir + '/fontawesome/fonts/**.*')
    .pipe(gulp.dest(config.publicDir + '/fonts'));
});

gulp.task('scripts', function() {
  return gulp.src([config.bowerDir + '/bootstrap-sass/assets/javascripts/bootstrap.js', config.bowerDir + '/jquery/dist/jquery.js'])
    .pipe(gulp.dest(config.publicDir + '/js'));
});

gulp.task('default', ['styles', 'icons', 'scripts'])