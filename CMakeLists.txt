cmake_minimum_required(VERSION 3.20)
project(${SKBUILD_PROJECT_NAME} VERSION ${SKBUILD_PROJECT_VERSION} LANGUAGES C)

set(BUILD_SHARED_LIBS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# --- Prepare Cython extensions ------------------------------------------------

set_property(GLOBAL PROPERTY PYTHON_EXTENSIONS_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/src)
include("src/scripts/cmake/CythonExtension.cmake")

# --- Setup include folders ----------------------------------------------------

# set(CYTHON_HEADERS_DIR ${CMAKE_CURRENT_LIST_DIR}/src/scoring_matrices)

# --- Compile source code ------------------------------------------------------

add_subdirectory(data)
add_subdirectory(src)
