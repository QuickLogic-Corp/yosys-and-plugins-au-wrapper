# yosys-and-plugins-au-wrapper

"wrapper" repo including yosys, and various yosys-plugins for aurora2 usage.

## Why

This repo is envisioned to wrap yosys, and plugins repos as submodules from the respective sources, and additionally, provide infrastructure code to build/test packages specific to Aurora2 usage patterns.

## Roadmap

- [ ] use yosys from the upstream YosysHQ repo
- [ ] introduce a Makefile system to build the 'techlibs/quicklogic' sources in upstream yosys as ql-qlf plugin
- [ ] introduce Makefile to run tests on ql-qlf plugin when built as above
- [ ] use the chipalliance yosys-plugins repo to build other required plugins (sdc)
- [ ] use synlig for sv support (experiment)
- [ ] use ghdl for vhdl support (experiment)
- [ ] integrate this into TabbyCAD build repo
