#include "filtro.h"

static float k_1 = 0;
static float k_2 = 0;
static float y_1 = 0;
static float y_2 = 0;

float filtro_digital(float k) {
    float y =   2.06*(10**(-5))*k_1 +
                2.054*(10**(-5))*k_2 +
                1.991*y_1 -
                0.991*y_2;
    k_2 = k_1;
    k_1 = k;
    y_2 = y_1;
    y_1 = y;
    return y;
}