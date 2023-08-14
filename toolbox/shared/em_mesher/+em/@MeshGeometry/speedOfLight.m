function vp=speedOfLight(eps_r,mu_r)

    eps_0=8.854187817e-12;
    mu_0=1.2566370614e-6;

    vp=1/sqrt(eps_0*eps_r*mu_0*mu_r);
