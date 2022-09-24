
#include <stdio.h>
#include <assert.h>

//------------------------------------------------------------------------------
// ENGINE API TEST - ZIG-CPP Experimental Bindings

#include "../bindings/engine.h"

//------------------------------------------------------------------------------

typedef struct Game {
	int i;
	float f;

	struct IEngine* engine;
} Game;

//@TODO(maple): Instead of declaring globals, let's allocate this struct
// from the memory passed from the Engine!
static Game g_game = {};
static IGame g_game_interface = {};

extern "C" void
gameInit(struct IGame* igame)
{
	// While I could just use the global game var, let's use the one
	// in the interface instead
	Game* game = (Game*)igame->ptr;

	game->i = 157;
	game->f = 16.45f;
}

extern "C" void
gameDeinit(struct IGame* igame)
{
	// While I could just use the global game var, let's use the one
	// in the interface instead
	Game* game = (Game*)igame->ptr;

	game->i = 0;
	game->f = 0.0f;
	game->engine = nullptr;

	igame->ptr = nullptr;
	igame->init = nullptr;
	igame->deinit = nullptr;
	igame->update = nullptr;
}

extern "C" void
gameUpdate(struct IGame* igame)
{
	Game* game = (Game*)igame->ptr;

	// Let's show that data is retained
	printf("testbed print int(%d) and float(%f)\n", game->i, game->f);

	//...and that we can call back into the engine!
	game->engine->print(game->i, game->f);
}

MAPIC struct IGame*
module_entry(struct IEngine* engine)
{
	printf("Hello from cpp testbed.\n");

	g_game.engine = engine;

	g_game_interface.ptr = &g_game;
	g_game_interface.init = gameInit;
	g_game_interface.deinit = gameDeinit;
	g_game_interface.update = gameUpdate;

	return &g_game_interface;
}
