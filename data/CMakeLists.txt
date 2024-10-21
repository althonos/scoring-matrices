file(GLOB MATRICES CONFIGURE_DEPENDS "*.mat")
set(GLOBAL PROPERTY MATRICES ${MATRICES})

add_custom_command(OUTPUT matrices.h
    COMMAND ${Python_EXECUTABLE} ${PROJECT_SOURCE_DIR}/src/scripts/generate_matrices.py --output matrices.h ${MATRICES}
    DEPENDS ${MATRICES}
)

file(CONFIGURE OUTPUT stub.c CONTENT "")

add_library(matrices matrices.h ${CMAKE_CURRENT_BINARY_DIR}/stub.c)
set_target_properties(matrices PROPERTIES LINKER_LANGUAGE C)
target_include_directories(matrices INTERFACE ${CMAKE_CURRENT_BINARY_DIR})

