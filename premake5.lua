-- Box2D v3 as a static library. Mirrors CMakeLists.txt and src/CMakeLists.txt with their default options:
-- C17, SIMD on (SSE2, plus AVX2 for the 8-wide contact solver only), single precision, no Tracy profiling.
-- The public headers are include/box2d/*.h: include them as <box2d/box2d.h>.
--
-- Projects that use Box2D call UseBox2D() for the include folder and the library.

local root = _SCRIPT_DIR

Box2DIncludeDir = root .. "/include"

-- For a project that includes Box2D's headers and links the library
function UseBox2D()
    includedirs { Box2DIncludeDir }
    links { "box2d" }
end

project "box2d"
    kind "StaticLib"
    language "C"
    cdialect "C17"
    staticruntime "on"

    targetdir("%{wks.location}/bin/" .. outputdir .. "/%{prj.name}")
    objdir("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.name}")

    files
    {
        root .. "/src/**.c",
        root .. "/src/**.h",
        root .. "/src/**.inl",
        root .. "/src/box2d.natvis",
        root .. "/include/box2d/**.h",
    }

    includedirs
    {
        root .. "/include",
        root .. "/src",
    }

    -- Upstream builds this one file with AVX2; the rest stays SSE2 and picks the solver at run time
    filter "files:**/contact_solver_w8.c"
        buildoptions { "/arch:AVX2" }
    filter {}

    filter "system:windows"
        systemversion "latest"
        -- Upstream: /Wall minus the noisy ones (padding, Spectre, enum switch, inlining notes)
        disablewarnings { "4820", "5045", "4061", "4711", "4710" }

    filter "configurations:Debug"
        runtime "Debug"
        symbols "on"

    filter "configurations:Release or configurations:Dist"
        runtime "Release"
        optimize "on"
        defines { "NDEBUG" } -- base.h turns B2_ASSERT off with NDEBUG, as CMake's Release does
    filter {}
