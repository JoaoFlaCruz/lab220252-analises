#include "pid_academico.h"

static float e_1 = 0;
static float e_2 = 0;

static float u_1 = 0;

float kp = 0.1;
float ki = 0.01;
float kd = 0.05;
float Ts = 0.1;

static float k1, k2, k3;

void pid_init(void) {
    k1 = kp * (1 + (Ts/(2.0f*(kp/ki))) + (kd/kp)/Ts);
    k2 = -kp * (1 - (Ts/(2.0f*(kp/ki))) + (2.0f*(kd/kp))/Ts);
    k3 = kp * ((kd/kp)/Ts);
}

float pid_academico(float e) {
    float u = u_1 + k1*e + k2*e_1 + k3*e_2;

    e_2 = e_1;
    e_1 = e;
    u_1 = u;

    return u;
}
