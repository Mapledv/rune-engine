#ifndef _ENGINE_CPP_BINDINGS_H_
#define _ENGINE_CPP_BINDINGS_H_

///
/// Prototpying "fake" CPP Bindings from the Zig Engine Interface.
/// Ideally, this proves that as long as a language can interface
/// with C, it can use the engine core module.
///

//----------------------------------------------------------------------------
// Engine Interface

typedef void (*ienginePrint_PFN)(int i, float f);

typedef struct IEngine {
	void* ptr;
	ienginePrint_PFN print;
} IEngine;

//----------------------------------------------------------------------------
// Game Interface

// Only exporting types from the file
#ifdef _MSC_VER
#  define MAPI __declspec(dllexport)
#else
#  define MAPI __attribute__((visibility("default")))
#endif

#define MAPIC extern "C" MAPI

//
// Function pointer for the exported function from the game DLL
//
// @TODO(maple): Ideally this will have the same signature as any other
// module, so need to move this over to the module syntax ASAP.
//
typedef struct IGame* igameEntry_PFN(struct IEngine* engine);

typedef void (*igameInit_PFN)(struct IGame* game);
typedef void (*igameUpdate_PFN)(struct IGame* game);
typedef void (*igameDeinit_PFN)(struct IGame* game);

typedef struct IGame {
	void*           ptr;
	igameInit_PFN   init;
	igameDeinit_PFN deinit;
	igameUpdate_PFN update;
} IGame;

#endif //_ENGINE_CPP_BINDINGS_H_