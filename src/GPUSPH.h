/*
 * GPUSPH.h
 *
 *  Created on: Jan 18, 2013
 *      Author: rustico
 */

#ifndef GPUSPH_H_
#define GPUSPH_H_

#include "Options.h"
#include "GlobalData.h"
#include "Problem.h"
// Including Synchronizer.h is acutally needed only in GPUSPH.cc.
// Should be follow our unusual convention to include in headers, or not?
#include "Synchronizer.h"
// IPPSCounter
#include "timing.h"

// The GPUSPH class is singleton. Wise tips about a correct singleton implementation are give here:
// http://stackoverflow.com/questions/1008019/c-singleton-design-pattern

// Note: this is not thread-safe, under both the singleoton point of view and the destructor.
// But aren't that paranoid, are we?

class GPUSPH {
private:
	// some pointers
	Options* clOptions;
	GlobalData* gdata;
	Problem* problem;
	//ParticleSystem* psystem;
	IPPSCounter *m_performanceCounter;
	// aux arrays for rollCallParticles()
	bool *m_rcBitmap;
	bool *m_rcNotified;
	uint *m_rcAddrs;

	// other vars
	bool initialized;

	// constructor and copy/assignment: private for singleton scheme
	GPUSPH();
	GPUSPH(GPUSPH const&); // NOT implemented
	void operator=(GPUSPH const&); // avoid the (unlikely) case of self-assignement

	// (de)allocation of shared host buffers
	long unsigned int allocateGlobalHostBuffers();
	void deallocateGlobalHostBuffers();

	// sort particles by device before uploading
	void sortParticlesByHash();
	// aux function for sorting; swaps particles in s_hPos, s_hVel, s_hInfo
	void particleSwap(uint idx1, uint idx2);

	// update s_hStartPerDevice and s_hPartsPerDevice
	void updateArrayIndices();

	// set nextCommand, unlock the threads and wait for them to complete
	void doCommand(CommandType cmd, uint flags = 0, float arg=NAN);

	// sets the correct viscosity coefficient according to the one set in SimParams
	void setViscosityCoefficient();

	// create the Writer
	void createWriter();

	// use the writer
	void doWrite();

	// callbacks fro moving boundaries and variable gravity
	void doCallBacks();

	// rebuild the neighbor list
	void buildNeibList();

	// initialization of semi-analytic boundary arrays
	void initializeGammaAndGradGamma();
	void imposeDynamicBoundaryConditions();
	void updateValuesAtBoundaryElements();

	// print information about the status of the simulation
	void printStatus();

	// print information about the status of the simulation
	void printParticleDistribution();

	// do a roll call of particle IDs
	void rollCallParticles();

	// initialize the centers of gravity of objects
	void initializeObjectsCGs();

public:
	// destructor
	~GPUSPH();

	// getInstance(), constructor and operator for singleton
	static GPUSPH* getInstance();

	// (de)initialization (include allocation)
	bool initialize(GlobalData* _gdata);
	bool finalize();

	/*static*/ bool runSimulation();

};

#endif // GPUSPH_H_