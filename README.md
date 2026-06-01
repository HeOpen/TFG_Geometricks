# Geometricks
![Logo](https://raw.githubusercontent.com/HeOpen/TFG_Geometricks/main/screenshots/logo_Geometrix.png)

Geometricks is a hybrid indie video game that blends 2D puzzles, escape room mechanics, and platforming under an oppressive psychological survival horror atmosphere.

## Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Screenshots](#screenshots)
4. [Installation](#installation)
5. [Gameplay](#gameplay)
6. [Technologies Used](#technologies-used)
7. [System Requirements](#system-requirements)
8. [Controls](#controls)
9. [Development Process](#development-process)
10. [Future Improvements](#future-improvements)
11. [Academic Context](#academic-context)
12. [Learning Outcomes](#learning-outcomes)
13. [Credits](#credits)
14. [License](#license)
15. [Acknowledgements](#acknowledgements)

    
## Overview

* Gameplay Showcase
* https://youtu.be/oo88JcLMy6g

Developed as a prototype and Final Project (TFG) for the Multiplatform Application Development CFGS (2024-2026), Geometricks operates on the Godot Engine 4 using the Vulkan Forward+ renderer. The narrative places the player in the year 2015 as a young film directing student who receives an anonymous package containing a mysterious VHS tape. Upon playing the tape, the player is teleported to a chaotic wooden cabin, representing the unstable mind of "The Hooded One," a sinister killer obsessed with cubism and Pablo Picasso.

The primary objective is to survive a strict 15-minute time limit by participating in a lethal board game known as the Millennium Cube. The player must explore the cabin in first-person, collect geometric shapes, and solve the enigma to avoid permanent geometric mutilation. The project transitioned from obsolete 2D board mechanics to heavily focus on the first-person survival horror experience.

## Features

* **2D/3D Perspective Shifts ("Tricks"):** The game forces the player to break the rules of the 2D orthographic board by physically standing up and exploring the 3D cabin environment in first-person.

* **Analog Horror & PSX Aesthetics:** The visual direction utilizes 32-bit era low-poly graphics. The rendering pipeline features aggressive post-processing, including VHS emission, chromatic aberration, and tape noise to obscure vision and generate psychological tension.

* **Oppressive Audio Design:** The game avoids sudden jumpscares. Tension is instead maintained through dark ambient tracks, industrial noise, and low frequencies.

* **Dynamic Transformations:** Players unlock real-world objects to use on the Millennium Cube, granting distinct geometric mutations.

## Screenshots

![Sunset_Intro](https://raw.githubusercontent.com/HeOpen/TFG_Geometricks/main/screenshots/Sunset.png)
![CRT_VHS](https://raw.githubusercontent.com/HeOpen/TFG_Geometricks/main/screenshots/CRT_VHS.png)
![Door_VHS](https://raw.githubusercontent.com/HeOpen/TFG_Geometricks/main/screenshots/Door_VHS.png)
![Fruits_VHS](https://raw.githubusercontent.com/HeOpen/TFG_Geometricks/main/screenshots/Fruits_VHS.png)
![RedDoor_VHS](https://raw.githubusercontent.com/HeOpen/TFG_Geometricks/main/screenshots/RedDoor_VHS.png)

## Installation

The precompiled binaries are available on the [GitHub Releases page](https://github.com/HeOpen/TFG_Geometricks/releases/latest).

The project is distributed as precompiled binaries and operates as a portable application requiring no system installation.

## Gameplay

The core gameplay loop requires the player to navigate the cabin using a flashlight to find items applicable to the six thematic faces of the Millennium Cube. Applying these items grants the player specific mutations to solve environmental puzzles:

* **Marble (Sphere):** The initial base figure. It moves rapidly and is the only form capable of jumping.

* **Rubik's Cube / Dice (Cube):** A heavy figure. Its weight allows the player to trigger floor pressure switches.

* **Glass Prism (Pyramid):** Grants the ability to fly vertically to reach otherwise inaccessible areas.

* **PS1 Memory Card (Cuboid):** Enables horizontal traversal and acts as a physical bridge to cross gaps.

Failure to solve the puzzle within the 15-minute threshold results in a game over state, narratively transforming the player into a geometric figure. Progressing to the basement acts as the mechanical and narrative point of no return.

## Technologies Used

| Technology   | Version | Use Case                                                     |
| ------------ | ------- | ------------------------------------------------------------ |
| Godot Engine | 4.6     | Core game engine, GDScript logic, hybrid 2D/3D rendering.    |
| Vulkan API   | 1.2+    | Forward+ rendering pipeline for dynamic global illumination. |
| Jolt Physics | 3D      | Advanced collision subsystem integration.                    |
| Blender      | 3.x+    | 3D modeling and environment asset creation.                  |
| GIMP         | -       | UI design and texture editing.                               |
| GitHub       | -       | Source code version control and repository hosting.          |

## System Requirements

The application requires hardware with full Vulkan API support due to dynamic global illumination and advanced post-processing.

### Minimum Requirements

* **OS:** Windows 10 (64-bit) / Linux (Ubuntu 22.04 LTS or Arch-based).
* **Processor:** Intel Core i3 / AMD Ryzen 3 or equivalent.
* **Memory:** 4 GB RAM.
* **Graphics:** Vulkan 1.2 compatible (NVIDIA GTX 660 / AMD Radeon RX 460 or higher).
* **Storage:** 500 MB available space.

### Recommended Requirements

* **OS:** Windows 10/11 (64-bit) / Linux.
* **Processor:** Intel Core i5 / AMD Ryzen 5.
* **Memory:** 8 GB RAM.
* **Graphics:** NVIDIA GTX 1060 / AMD Radeon RX 580 or higher.

## Controls

The game is designed for PC and fully supports standard keyboard/mouse capture as well as gamepad input.

### 3D Controls (The Cabin)

| Action       | Keyboard/Mouse     | Gamepad        |
| ------------ | ------------------ | -------------- |
| Move Player  | `W` `A` `S` `D`    | Left Joystick  |
| Move Camera  | Mouse              | Right Joystick |
| Interact     | `Left Click` / `E` | Button A       |
| Menu / Pause | `Esc`              | Start          |

### 2D Controls (The Millennium Cube)

| Action                | Keyboard | Gamepad       |
| --------------------- | -------- | ------------- |
| Move Player           | `A` `D`  | Left Joystick |
| Jump                  | `Space`  | Left Joystick |
| Change Form (Sphere)  | `1`      | Button RB     |
| Change Form (Cube)    | `2`      | Button RT     |
| Change Form (Pyramid) | `3`      | Button LB     |
| Change Form (Cuboid)  | `4`      | Button LT     |
| Exit 2D Mode          | `Esc`    | Start         |

## Development Process

* **Planning:** Definition of the core 15-minute survival mechanic and the 2D/3D hybrid constraint.
* **Design:** Drafting the narrative of "The Hooded One" and the low-poly PSX visual identity.
* **Implementation:** Developing the custom character controllers in GDScript and integrating Jolt physics.
* **Testing:** Resolving edge cases with geometric collision sizes and camera transitions.
* **Optimization:** Adjusting the Vulkan Forward+ renderer settings to ensure stable performance despite heavy post-processing.

## Future Improvements

* Implementation of Virtual Reality (VR) support to heighten the first-person psychological horror.
* Addition of procedurally generated puzzles on the Millennium Cube to increase replayability.
* Expansion of the narrative lore regarding "The Hooded One" via environmental storytelling.

## Academic Context

This project represents the Final Project (Trabajo Fin de Grado) for the Higher Level Training Cycle (CFGS) in Multiplatform Application Development (2024-2026), developed by students at IES Clara del Rey. It adheres strictly to the technical and formatting structure required for a professional software repository.

## Learning Outcomes

* Mastery of the Godot Engine 4 API and GDScript programming.
* Implementation of hybrid 2D and 3D rendering pipelines.
* Version control and collaborative development via GitHub.
* Advanced 3D modeling and texturing for legacy hardware aesthetics (PSX era).

## Credits

Development Team (Cubama Studios):

* **Jose Espadas (Espadas995):** Programming and 2D Design
* **Alejandro Zelada (A-Zelada):** Programming and 2D Design
* **Eliabe Olah (HeOpen):** 3D Modeling, Environments, and Programming
* **Elvis Danciu (ElvisFD):** 3D Modeling, Environments, and Programming

### Academic Supervision

* **TFG Tutor:** Mario Nuñez Jimenez

## License

**Resources:**

* Base assets and resources sourced via Itch.io and Sketchfab under CC-0 and applicable licenses.

> ⚠️ **LEGAL AND COPYRIGHT NOTICE - STRICTLY ACADEMIC PROJECT** ⚠️
>
> **GEOMETRICKS** is a prototype developed **EXCLUSIVELY for educational and academic evaluation purposes** for the Final Degree Project (TFG) of the CFGS on Multiplatform Application Development at the IES Clara del Rey (Promotion 2024-2026).
>
> **THIS PROJECT IS NON-PROFIT, IS NOT COMMERCIAL AND WILL NOT BE DISTRIBUTED TO THE PUBLIC IN DIGITAL STORES.**
>
> The pictorial works of art (including those by Pablo Picasso, Salvador Dalí and other contemporary artists) as well as the audio tracks (belonging to the *Silent Hill* / Konami franchise) present in this repository are the exclusive intellectual property of their respective authors, heirs or rights management entities.
>
> These Copyright-protected materials have been integrated into the source code solely and exclusively under the protection of the **exception of illustration for educational purposes and "Fair Use"**. Cubama Studios does not claim any ownership, right or authorship over these third-party assets, and the repository exists solely as a support and test of the software architecture developed by the students.

© 2026 Cubama Studios. All rights reserved.

<p align="center">
  <img src="https://raw.githubusercontent.com/HeOpen/TFG_Geometricks/main/screenshots/LogoCubama%20(1).png" alt="Cubama Studios Logo" width="100" height="100" style="border: 2px solid orange; padding: 5px;">
</p>

![PSX_Jewel_Case](https://raw.githubusercontent.com/HeOpen/TFG_Geometricks/main/screenshots/PS1_FullJewelCase.png)

The source code, narrative design, and mechanical implementations are the exclusive property of Cubama Studios. Third-party 3D models, textures, and sound effects belong to their respective authors and are utilized under license (refer to the Credits section for detailed attributions).

## Acknowledgements

Special thanks to the IES Clara del Rey faculty, the Godot open-source community, and everyone who playtested the early builds of the Millennium Cube to help refine the puzzle mechanics.
