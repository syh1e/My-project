import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useParams } from 'react-router-dom';

const About = () => {
    const { id } = useParams();
    const [pokemonDetails, setPokemonDetails] = useState(null);

    useEffect(() => {
        const fetchPokemonDetails = async () => {
            try {
                const res = await axios.get(`https://pokeapi.co/api/v2/pokemon/${id}`);
                setPokemonDetails(res.data);
                console.log("Pokemon Details:", res.data); // Log the details
            } catch (error) {
                console.log('Error fetching Pokemon details:', error);
            }
        };

        fetchPokemonDetails();
    }, [id]);

    if (!pokemonDetails) return <div>Loading...</div>;

    return (
        <div>
            <h1>{pokemonDetails.name}</h1>
            <img src={pokemonDetails.sprites.front_default} alt={pokemonDetails.name} />
            <p>Height: {pokemonDetails.height}</p>
            <p>Weight: {pokemonDetails.weight}</p>
            <p>Types: {pokemonDetails.types.map(t => t.type.name).join(', ')}</p>
        </div>
    );
};

export default About;
