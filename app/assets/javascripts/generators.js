//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://coffeescript.org/

var container, stats;

var camera, scene, renderer;

var mouseX = 0, mouseY = 0;

var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;

function init() {

    container = document.createElement( 'div' );
    document.body.appendChild( container );

    camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 2000 );
    camera.position.z = 100;

    // scene

    scene = new THREE.Scene();

    var ambient = new THREE.AmbientLight( 0x101030 );
    scene.add( ambient );

    var directionalLight = new THREE.DirectionalLight( 0xffeedd );
    directionalLight.position.set( 0, 0, 1 );
    scene.add( directionalLight );

    // texture

    var manager = new THREE.LoadingManager();
    manager.onProgress = function ( item, loaded, total ) {

        try{
            console.log( item, loaded, total );
        } catch(err){
            console.log("Error logging in THREE.js: " + err.toString() );
        }

    };

    var texture = new THREE.Texture();

    var loader = new THREE.ImageLoader( manager );
    loader.load( '/textures/ash_uvgrid01.jpg', function ( image ) {

        texture.image = image;
        texture.needsUpdate = true;

    } );

    // model

    var loader = new THREE.OBJLoader( manager );
    loader.load( getObjPath(), function ( object ) {

        object.traverse( function ( child ) {

            if ( child instanceof THREE.Mesh ) {

                child.material.map = texture;

            }

        } );

        object.position.y = - 80;
        scene.add( object );

    } );

    //

    renderer = new THREE.WebGLRenderer();
    renderer.setSize( window.innerWidth, window.innerHeight );
    container.appendChild( renderer.domElement );

    document.addEventListener( 'mousemove', onDocumentMouseMove, false );

    //

    window.addEventListener( 'resize', onWindowResize, false );

}

function onWindowResize() {

    windowHalfX = window.innerWidth / 2;
    windowHalfY = window.innerHeight / 2;

    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize( window.innerWidth, window.innerHeight );

}

function onDocumentMouseMove( event ) {

    mouseX = ( event.clientX - windowHalfX ) / 2;
    mouseY = ( event.clientY - windowHalfY ) / 2;

}

//

function animate() {

    requestAnimationFrame( animate );
    render();

}

function render() {

    camera.position.x += ( mouseX - camera.position.x ) * .05;
    camera.position.y += ( - mouseY - camera.position.y ) * .05;

    camera.lookAt( scene.position );

    renderer.render( scene, camera );

}

function getObjPath(){
    return obj_path;
}


$(document).ready(function() {
    init();
    animate();
});
