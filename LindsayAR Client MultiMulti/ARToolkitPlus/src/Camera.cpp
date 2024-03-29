/**
 * Copyright (C) 2010  ARToolkitPlus Authors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *  Thomas Pintaric
 *  Pavel Rojtberg
 */

#include <cstdlib>
#include <clocale>
#include <cstdio>
#include <cmath>
#include <cstring>

#include "Camera.h"

namespace ARToolKitPlus {

bool Camera::loadFromFile(const char* filename) {
	
    setlocale(LC_NUMERIC, "C");
    FILE *fp = fopen(filename, "r");

    if (fp == NULL)
        return (false);

    fileName = filename;

    double _cc[2];
    double _fc[2];
    double _kc[6];
    int n;

    char _s[32];
    sprintf(_s, "%%%is\n", (int)strlen(CAMERA_ADV_HEADER));
    char hdr[strlen(CAMERA_ADV_HEADER)];
    n = fscanf(fp, _s, hdr);
    if (strcmp(hdr, CAMERA_ADV_HEADER) != 0)
        return false;

    n = fscanf(fp, "%d%d%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%d\n", &this->xsize, &this->ysize, &_cc[0], &_cc[1], &_fc[0],
            &_fc[1], &_kc[0], &_kc[1], &_kc[2], &_kc[3], &_kc[4], &_kc[5], &undist_iterations);

    if ((n != 13) || ferror(fp)) {
        return (false);
    }

    unsigned int i, j;
    this->cc[0] = (ARFloat) _cc[0];
    this->cc[1] = (ARFloat) _cc[1];
    this->fc[0] = (ARFloat) _fc[0];
    this->fc[1] = (ARFloat) _fc[1];
    for (i = 0; i < 6; i++)
        this->kc[i] = (ARFloat) _kc[i];

    for (i = 0; i < 3; i++)
        for (j = 0; j < 4; j++)
            this->mat[i][j] = 0.;

    mat[0][0] = fc[0]; // fc_x
    mat[1][1] = fc[1]; // fc_y
    mat[0][2] = cc[0]; // cc_x
    mat[1][2] = cc[1]; // cc_y
    mat[2][2] = 1.0;

    if (undist_iterations > CAMERA_ADV_MAX_UNDIST_ITERATIONS)
        undist_iterations = CAMERA_ADV_MAX_UNDIST_ITERATIONS;

    fclose(fp);
    setlocale(LC_NUMERIC, ""); // valgrind does not like this one..
    return true;
}

void Camera::observ2Ideal(ARFloat ox, ARFloat oy, ARFloat *ix, ARFloat *iy) {
    if (undist_iterations <= 0) {
        *ix = ox;
        *iy = oy;
    } else {
        const ARFloat xd[2] = { (ox - cc[0]) / fc[0], (oy - cc[1]) / fc[1] };
        const ARFloat k1 = kc[0];
        const ARFloat k2 = kc[1];
        const ARFloat k3 = kc[4];
        const ARFloat p1 = kc[2];
        const ARFloat p2 = kc[3];

        ARFloat x[2] = { xd[0], xd[1] };
        for (int kk = 0; kk < undist_iterations; kk++) {
            const ARFloat x0_sq = (x[0] * x[0]);
            const ARFloat x1_sq = (x[1] * x[1]);
            const ARFloat x0_x1 = (x[0] * x[1]);
            const ARFloat r_2 = x0_sq + x1_sq;
            const ARFloat r_2_sq = (r_2 * r_2);
            const ARFloat k_radial = 1 + k1 * r_2 + k2 * (r_2_sq) + k3 * (r_2 * r_2_sq);
            const ARFloat delta_x[2] = { 2 * p1 * x0_x1 + p2 * (r_2 + 2 * x0_sq), p1 * (r_2 + 2 * x1_sq) + 2 * p2
                    * x0_x1 };
            x[0] = xd[0] - delta_x[0];
            x[1] = xd[1] - delta_x[1];
            x[0] /= k_radial;
            x[1] /= k_radial;
        }

        *ix = (x[0] * fc[0]) + cc[0];
        *iy = (x[1] * fc[1]) + cc[1];
    }
}

void Camera::ideal2Observ(ARFloat ix, ARFloat iy, ARFloat *ox, ARFloat *oy) {
    const ARFloat xu[2] = { (ix - cc[0]) / fc[0], (iy - cc[1]) / fc[1] };

    const ARFloat r2 = (xu[0] * xu[0]) + (xu[1] * xu[1]);
    const ARFloat r4 = r2 * r2;
    const ARFloat r6 = r4 * r2;
    const ARFloat cdist = 1 + kc[0] * r2 + kc[1] * r4 + kc[4] * r6;

    const ARFloat a1 = 2 * xu[0] * xu[1];
    const ARFloat a2 = r2 + 2 * (xu[0] * xu[0]);
    const ARFloat a3 = r2 + 2 * (xu[1] * xu[1]);

    *ox = (xu[0] * cdist) + (kc[2] * a1 + kc[3] * a2);
    *oy = (xu[1] * cdist) + (kc[2] * a3 + kc[3] * a1);
}

Camera* Camera::clone() {
    Camera* pCam = new Camera();
    pCam->xsize = xsize;
    pCam->ysize = ysize;
    unsigned int i, j;
    for (i = 0; i < 3; i++)
        for (j = 0; j < 4; j++)
            pCam->mat[i][j] = mat[i][j];
    for (i = 0; i < 4; i++)
        pCam->dist_factor[i] = dist_factor[i];
    pCam->cc[0] = cc[0];
    pCam->cc[1] = cc[1];
    pCam->fc[0] = fc[0];
    pCam->fc[1] = fc[1];
    for (i = 0; i < 6; i++)
        pCam->kc[i] = kc[i];
    pCam->undist_iterations = undist_iterations;
    return ((Camera*) pCam);
}

bool Camera::changeFrameSize(const int frameWidth, const int frameHeight) {
    if (frameWidth <= 0 || frameHeight <= 0)
        return (false);
    const ARFloat scale = (ARFloat) frameWidth / (ARFloat) xsize;
    xsize = frameWidth;
    ysize = frameHeight;

    for (int i = 0; i < 4; i++) {
        mat[0][i] *= scale;
        mat[1][i] *= scale;
    }

    cc[0] *= scale;
    cc[1] *= scale;
    fc[0] *= scale;
    fc[1] *= scale;

    return (true);
}

void Camera::printSettings() {
    printf("ARToolKitPlus: CamSize %d , %d\n", xsize, ysize);
    printf("ARToolKitPlus: cc = [%.2f  %.2f]  fc = [%.2f  %.2f]\n", cc[0], cc[1], fc[0], fc[1]);
    printf("ARToolKitPlus: kc = [%.4f %.4f %.4f %.4f %.4f %.4f]\n", kc[0], kc[1], kc[2], kc[3], kc[4], kc[5]);
    printf("ARToolKitPlus: undist_iterations = %i\n", undist_iterations);
}

string Camera::getFileName() const {
    return fileName;
}

} // namespace ARToolKitPlus
