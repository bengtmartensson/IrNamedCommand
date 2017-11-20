#ifndef RC5COMMAND_H
#define	RC5COMMAND_H

#include "IrNamedCommand.h"
#include "Rc5Renderer.h"

class NamedRc5Command : public IrNamedCommand {
public:

    NamedRc5Command(const char* name, uint8_t D_, uint8_t F_) : IrNamedCommand(name), D(D_) {
        F = F_;
    };

    virtual ~NamedRc5Command() {
    };

    const IrSignal *getIrSignal() const {
        return Rc5Renderer::newIrSignal(D, F);
    };
private:
    // NOTE: There is no T here, but there is a (persistent, static) T in Rc5Render.
    uint8_t D;
    uint8_t F;
};

#endif	/* RC5COMMAND_H */
