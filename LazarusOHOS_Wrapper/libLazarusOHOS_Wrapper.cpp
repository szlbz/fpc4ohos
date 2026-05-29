// libLazarusOHOS_Wrapper.cpp - HarmonyOS Qt5 + Lazarus LCL wrapper
// QApplication is already created by Qt OHOS plugin (libqohos.so)
// before this library is loaded. Do NOT create another one.

#include <QApplication>
#include <dlfcn.h>

typedef void (*InitAndShowFormFunc)();

extern "C" int main(int, char**)
{
    // QApplication already exists from libqohos.so, do NOT create one.
    // Load the Lazarus library and find InitAndShowForm symbol.
    void* lib = dlopen("libOHOS_QT_Lazarus.so", RTLD_NOW | RTLD_GLOBAL);
    if (!lib)
        return 1;
    InitAndShowFormFunc InitAndShowForm = (InitAndShowFormFunc)dlsym(lib, "InitAndShowForm");
    if (!InitAndShowForm)
        return 1;
    InitAndShowForm();
    return 0;
}
