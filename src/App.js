import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { BrowserRouter as Router, Routes, Route, Link, useNavigate, useLocation } from 'react-router-dom';
import Pagination from 'react-js-pagination';
import './App.css';

const baseURL = 'https://pokeapi.co/api/v2';

const typeTranslations = {
    normal: '노말',
    fire: '불꽃',
    water: '물',
    grass: '풀',
    electric: '전기',
    ice: '얼음',
    fighting: '격투',
    poison: '독',
    ground: '땅',
    flying: '비행',
    psychic: '에스퍼',
    bug: '벌레',
    rock: '바위',
    ghost: '고스트',
    dark: '악',
    dragon: '드래곤',
    steel: '강철',
    fairy: '페어리'
};

function App() {
    const [pokemonData, setPokemonData] = useState([]);
    const [selectedTypes, setSelectedTypes] = useState(() => {
        const storedFilters = localStorage.getItem('selectedTypes');
        return storedFilters ? JSON.parse(storedFilters) : [];
    });
    const [isDarkMode, setIsDarkMode] = useState(() => {
        const storedMode = localStorage.getItem('isDarkMode');
        return storedMode === 'true';
    });
    const [activePage, setActivePage] = useState(1);
    const itemsPerPage = 10;

    useEffect(() => {
        localStorage.setItem('isDarkMode', isDarkMode);
    }, [isDarkMode]);

    useEffect(() => {
        localStorage.setItem('selectedTypes', JSON.stringify(selectedTypes));
    }, [selectedTypes]);

    useEffect(() => {
        const fetchPokemon = async () => {
            try {
                const res = await axios.get(`${baseURL}/pokemon?offset=0&limit=100`);
                const pokemonList = res.data.results;

                const allPokemonData = [];
                for (const pokemon of pokemonList) {
                    const speciesRes = await axios.get(pokemon.url);
                    const speciesData = await axios.get(speciesRes.data.species.url);
                    const koreanName = speciesData.data.names.find(name => name.language.name === 'ko');

                    allPokemonData.push({
                        id: pokemon.url.split('/').slice(-2, -1)[0],
                        title: koreanName ? koreanName.name : pokemon.name,
                        sprite: speciesRes.data.sprites.front_default,
                        types: speciesRes.data.types.map(t => typeTranslations[t.type.name] || t.type.name)
                    });
                }
                setPokemonData(allPokemonData);
            } catch (err) {
                console.log(err);
            }
        };

        fetchPokemon();
    }, []);

    const filteredPokemons = pokemonData.filter((pokemon) =>
        selectedTypes.length === 0 || pokemon.types.some(type => selectedTypes.includes(type))
    );

    const handleTypeChange = (type) => {
        setSelectedTypes((prev) =>
            prev.includes(type) ? prev.filter((t) => t !== type) : [...prev, type]
        );
    };

    const handlePageChange = (pageNumber) => {
        setActivePage(pageNumber);
    };

    const paginatedPokemons = filteredPokemons.slice((activePage - 1) * itemsPerPage, activePage * itemsPerPage);

    const navigate = useNavigate();

    const openPokemonDetail = (pokemon) => {
        navigate(`/pokemon/${pokemon.id}`, { state: pokemon });
    };

    return (
        <div className={`App ${isDarkMode ? 'dark-mode' : 'light-mode'}`}>
            <header>
                <img src="/header.png" alt="Header" className="header-image" />
            </header>

            <div className="black-box">
                <div className="filter-options">
                    {Array.from(new Set(pokemonData.flatMap(pokemon => pokemon.types))).map((type) => (
                        <label key={type}>
                            <input
                                type="checkbox"
                                checked={selectedTypes.includes(type)}
                                onChange={() => handleTypeChange(type)}
                            />
                            {type}
                        </label>
                    ))}
                </div>
                <label className="switch">
                    <input
                        type="checkbox"
                        onChange={() => setIsDarkMode(!isDarkMode)}
                        checked={isDarkMode}
                    />
                    <span className="slider"></span>
                </label>
            </div>

            <main className="grid-container">
                {paginatedPokemons.map((pokemon, index) => (
                    <div
                        key={index}
                        className="pokemon-card"
                        style={{ cursor: 'pointer' }}
                        onClick={() => openPokemonDetail(pokemon)}
                    >
                        <h2>{pokemon.title}</h2>
                        <img src={pokemon.sprite} alt={pokemon.title} />
                        <p>{pokemon.types.join(', ')}</p>
                    </div>
                ))}
            </main>

            <Pagination
                activePage={activePage}
                itemsCountPerPage={itemsPerPage}
                totalItemsCount={filteredPokemons.length}
                pageRangeDisplayed={5}
                onChange={handlePageChange}
                innerClass="pagination"
            />
        </div>
    );
}

function PokemonDetail() {
    const { state } = useLocation();

    if (!state) {
        return <p>잘못된 접근입니다. 포켓몬을 선택해 주세요.</p>;
    }

    const { title, sprite, types } = state;

    return (
        <div className="pokemon-detail">
            <h2>{title}</h2>
            <img src={sprite} alt={title} />
            <p>타입: {types.join(', ')}</p>
            <Link to="/">목록으로 돌아가기</Link>
        </div>
    );
}

function SplashScreen({ onFinish }) {
    useEffect(() => {
        const timer = setTimeout(() => {
            onFinish();
        }, 3000);
        return () => clearTimeout(timer);
    }, [onFinish]);

    return (
        <div className="splash-screen">
            <img src="/header.png" alt="Splash Screen" className="splash-image" />
        </div>
    );
}

function AppWrapper() {
    const [showSplash, setShowSplash] = useState(true);

    const handleSplashFinish = () => {
        setShowSplash(false);
    };

    return (
        <Router>
            {showSplash ? (
                <SplashScreen onFinish={handleSplashFinish} />
            ) : (
                <Routes>
                    <Route path="/" element={<App />} />
                    <Route path="/pokemon/:id" element={<PokemonDetail />} />
                </Routes>
            )}
        </Router>
    );
}

export default AppWrapper;
