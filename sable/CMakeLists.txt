# SableOS Native's part of the CMake build. Registered from the root
# CMakeLists.txt by one hook line (sable/docs/HOOKS.md), so Marathon's CTest
# run also runs SableOS tests and its test-reachability lint can see them.

if(BUILD_TESTING)
    set(_sable_cargo_flags --locked)
    if(MARATHON_CARGO_OFFLINE)
        list(APPEND _sable_cargo_flags --offline)
    endif()
    add_test(NAME Sable_Crates
        COMMAND ${CMAKE_COMMAND} -E env "CARGO_TARGET_DIR=${CMAKE_BINARY_DIR}/sable-cargo"
                "${MARATHON_CARGO}" test --workspace ${_sable_cargo_flags}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/crates")
endif()
