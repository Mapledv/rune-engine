#ifndef _INTEROP_H
#define _INTEROP_H

//typedef void (*print_PFN)(struct TestbedModule* ptr, struct EngineInterface* interface);
//typedef void (*printInterface_PFN)(int i, float f);

typedef struct TestbedModule {
    int a;
    float f;
    void (*print)(struct TestbedModule* ptr, struct IEngine* interface);
} TestbedModule;

#endif