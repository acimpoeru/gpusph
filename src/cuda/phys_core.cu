/*! \file
 * Physical constants used by all kernels
 */

#ifndef _PHYS_CORE_
#define _PHYS_CORE_

#include "particledefine.h"

namespace cuphys {
__constant__ uint	d_numfluids;			///< number of different fluids

__constant__ float	d_sqC0[MAX_FLUID_TYPES];	///< square of sound speed for at-rest density for each fluid

__constant__ float	d_densityDiffCoeff;			///< coefficient for density diffusion

__constant__ float	d_epsinterface;			///< interface epsilon for simplified surface tension in Grenier

// LJ boundary repusion force comuting
__constant__ float	d_dcoeff;
__constant__ float	d_p1coeff;
__constant__ float	d_p2coeff;
__constant__ float	d_r0;

// Monaghan-Kaijar boundary repulsion force constants
__constant__ float	d_MK_K;		///< This is typically the square of the maximum velocity, or gravity times the maximum height
__constant__ float	d_MK_d;		///< This is typically the distance between boundary particles
__constant__ float	d_MK_beta;	///< This is typically the ration between h and the distance between boundary particles

__constant__ float	d_visccoeff[MAX_FLUID_TYPES];	///< viscous coefficient for laminar viscosity

// Artificial viscosity parameters
__constant__ float	d_artvisccoeff;					///< viscous coefficient for artificial viscosity
__constant__ float	d_epsartvisc;					///< epsilon of artificial viscosity

// Sub-Particle Scale (SPS) Turbulence parameters
__constant__ float	d_smagfactor;
__constant__ float	d_kspsfactor;

__constant__ float	d_partsurf;		///< particle surface (typically particle spacing suared)

// Free surface detection
__constant__ float	d_cosconeanglefluid;
__constant__ float	d_cosconeanglenonfluid;

// physical constants
__constant__ float	d_rho0[MAX_FLUID_TYPES];		// rest density of fluids
__constant__ float3	d_gravity;						// gravity (vector)
// speed of sound constants
__constant__ float	d_bcoeff[MAX_FLUID_TYPES];		// \rho_0 c_0^2 / \gamma
__constant__ float	d_gammacoeff[MAX_FLUID_TYPES];	// \gamma
__constant__ float	d_sscoeff[MAX_FLUID_TYPES];		// c_0
__constant__ float	d_sspowercoeff[MAX_FLUID_TYPES];// (\gamma - 1)/2


/********************** Equation of state, speed of sound, repulsive force **********************************/
// Equation of state: pressure from density, where i is the fluid kind, not particle_id

__device__ __forceinline__ float
P(const float rho_tilde, const ushort i)
{
	const float rho_ratio = rho_tilde + 1.0f; // rho/rho0
	return d_bcoeff[i]*(__powf(rho_ratio, d_gammacoeff[i]) - 1.0f);
}

// Inverse equation of state: density from pressure, where i is the fluid kind, not particle_id
//RHO returns rho_tilde = rho/rho0 - 1
__device__ __forceinline__ float
RHO(const float p, const ushort i)
{
	return __powf(p/d_bcoeff[i] + 1.0f, 1.0f/d_gammacoeff[i]) - 1.0; 
}

// Riemann celerity
__device__ float
R(const float rho_tilde, const ushort i)
{
	const float rho_ratio = rho_tilde + 1.0f; // rho/rho0
	return 2.0f/(d_gammacoeff[i]-1.0f)*d_sscoeff[i]*__powf(rho_ratio, 0.5f*d_gammacoeff[i]-0.5f);
}

// Relative density from Riemann celerity
__device__ __forceinline__ float
RHOR(const float r, const ushort i)
{
	return __powf((d_gammacoeff[i]-1.)*r/(2.*d_sscoeff[i]), 2./(d_gammacoeff[i]-1.)) -1.0;
}

// Sound speed computed from density
__device__ __forceinline__ float
soundSpeed(const float rho_tilde, const ushort i)
{
	const float rho_ratio = rho_tilde + 1.0; // rho/rho0
	return d_sscoeff[i]*__powf(rho_ratio, d_sspowercoeff[i]);
}

// returns physical density from numerical (stored) density
__device__ __forceinline__ float
physical_density(const float rho_tilde, const ushort i)
{
	return (rho_tilde + 1.0f)*d_rho0[i];
}

// Uniform precision on density
// returns the numerical (stored) density from physical density
__device__ __forceinline__ float
numerical_density(const float rho, const ushort i)
{
	return rho/d_rho0[i] - 1.0f;
}

}
#endif