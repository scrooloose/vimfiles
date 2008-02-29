GEEK_COMMENT OpenGL template by nick, v1.0
GEEK_YN_have_stdlib.h
#include <stdlib.h>
GEEK_END_YN
#include <GL/glut.h>

int windowWidth = GEEK_VAL_windowWidth;
int windowHeight = GEEK_VAL_windowHeight;

void init() {
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_COLOR_MATERIAL);

    glClearColor(0.0, 0.0, 0.0, 0.0); // set the background to black
}

void display() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    //draw something here

    glFlush();
    glutSwapBuffers();
}

void keyPressed(unsigned char key, int x, int y) {
    switch (key) {
        case 27:
            exit(0);
    }
}
GEEK_BEGIN_SWITCH_all_standard_function_skels
    GEEK_CASE_include_em_all
void resize(int w1, int h1) { }
void animate(void) { }
void visible(int state) { }
void splKeyPressed(int key, int x, int y) { }
void splKeyReleased(int key, int x, int y) { }
void keyReleased(unsigned char key, int x, int y) { }
void mouseClicked(int button, int state, int x, int y) { }
void mouseMoved(int mX, int mY) { }
    GEEK_CASE_prompt_about_them_indivdually
        GEEK_YN_resize
void resize(int w1, int h1) { }
        GEEK_END_YN
        GEEK_YN_animate
void animate(void) { }
        GEEK_END_YN
        GEEK_YN_visible
void visible(int state) { }
        GEEK_END_YN
        GEEK_YN_splKeyPressed
void splKeyPressed(int key, int x, int y) { }
        GEEK_END_YN
        GEEK_YN_ignore_key_repeat
            GEEK_YN_splKeyReleased
void splKeyReleased(int key, int x, int y) { }
            GEEK_END_YN
            GEEK_YN_keyReleased
void keyReleased(unsigned char key, int x, int y) { }
            GEEK_END_YN
        GEEK_END_YN
        GEEK_YN_mouseClicked
void mouseClicked(int button, int state, int x, int y) { }
        GEEK_END_YN
        GEEK_YN_mouseMoved
void mouseMoved(int mX, int mY) { }
        GEEK_END_YN
    GEEK_CASE_include_none_of_them
GEEK_END_SWITCH

int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(windowWidth, windowHeight);
    glutInitWindowPosition(0,0);
    glutCreateWindow("GEEK_VAL_Window_title");
    glutKeyboardFunc(keyPressed);
    glutDisplayFunc(display);
GEEK_BEGIN_SWITCH_all_standard_function_skels
    GEEK_CASE_include_em_all
    glutReshapeFunc(resize);
    glutMouseFunc(mouseClicked);
    glutMotionFunc(mouseMoved);
    glutIdleFunc(animate);
    glutVisibilityFunc(visible);
    glutSpecialFunc(splKeyPressed);
    GEEK_YN_keyReleased
    glutKeyboardUpFunc(keyReleased);
    GEEK_END_YN
    GEEK_YN_splKeyReleased
    glutSpecialUpFunc(splKeyReleased);
    GEEK_END_YN
    glutIgnoreKeyRepeat(1);
    GEEK_CASE_prompt_about_them_indivdually
GEEK_YN_resize
    glutReshapeFunc(resize);
GEEK_END_YN
GEEK_YN_mouseClicked
    glutMouseFunc(mouseClicked);
GEEK_END_YN
GEEK_YN_mouseMoved
    glutMotionFunc(mouseMoved);
GEEK_END_YN
GEEK_YN_animate
    glutIdleFunc(animate);
GEEK_END_YN
GEEK_YN_visible
    glutVisibilityFunc(visible);
GEEK_END_YN
GEEK_YN_splKeyPressed
    glutSpecialFunc(splKeyPressed);
GEEK_END_YN
GEEK_YN_ignore_key_repeat
    GEEK_YN_keyReleased
    glutKeyboardUpFunc(keyReleased);
    GEEK_END_YN
    GEEK_YN_splKeyReleased
    glutSpecialUpFunc(splKeyReleased);
    GEEK_END_YN
    glutIgnoreKeyRepeat(1);
GEEK_END_YN
    GEEK_CASE_include_none_of_them
GEEK_END_SWITCH

   init();
   glutMainLoop();
   return 0;
} 
